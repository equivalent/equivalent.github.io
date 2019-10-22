---
layout: til_post
categories: til
title:  "Retry ActiveJob (Sidekiq) on exception"
disq_id: til-70
---


Let say we have a simple Ruby on Rails ActiveJob background job that
would do something in a Background. For example


```ruby
# app/jobs/new_work_published_job.rb
class NotifyThatWorkWasPublishedJob < ActiveJob::Base
  queue_as :notifications

  def perform(work_id:)
    work = Work.find_by!(id: work_id)

    # ...some logic that will send Email, Push notification etc.
  end
end

# trigger
work = Work.create(title: 'hello', author_email: 'foo@bar.eu')
NotifyThatWorkWasPublishedJob.perform_later(work_id: work.id)
```


Now there are many things that can go wrong when doing architecture with
background jobs.

Sometimes you may be dealing with a situation where
Jobs will get queued and triggered to perform before the transaction to
relational database is finished. This happens quite often with
technology like [Sidekiq](https://github.com/mperham/sidekiq) where the queue mechanism is based on Redis
database which is much faster than PostgreSQL.

> When your application uses mix of database technologies you need to understand you are dealing with non-ATOMIC environment where code may get executed in different order as triggered.

In Rails applications this usually happens when you use
ActiveJob.pefrorm_later triggering other ActiveJob.pefrorm_later jobs.

> Theory of background jobs is that you want to finish background job as soon as possible. So
> it's better to trigger one job that will trigger 1000 other smaller jobs
> rather than to trigger one big job that would execute several
> seconds/minutes as those long running jobs may time out.


So let's imagine our job was queued before the `work` record was
saved in DB. We would see some error in Sidekiq retry tab saying something
like `ActiveRecord::NotFound`. Now it's no big deal the job will get
retried bit later (with Sidekiq) but the thing is we may see this error
pop up in error capture tool like Airbrake.

So it's better if we prevent this error from  happening ourself. This way  we have full controll of Job
lifecycle.


### Retry

One way to do this by using Ruby `retry` ([doc](https://docs.ruby-lang.org/en/2.4.0/syntax/exceptions_rdoc.html)):


```ruby
# app/jobs/new_work_published_job.rb
class NotifyThatWorkWasPublishedJob < ActiveJob::Base
  WorkNotFound = Class.new(StandardError)
  WorkNotFoundEvenAfterRetry = Class.new(StandardError)

  queue_as :notifications

  def perform(work_id:)
    attempt = 0

    begin
      attempt = attempt + 1
      work = Work.find_by(id: work_id) || raise(WorkNotFound)

      # ...some logic that will send Email, Push notification etc.

    rescue WorkNotFound
       if attempt < 4
         sleep 1  # wait a bit
         retry
       else
         raise(WorkNotFoundEvenAfterRetry)
       end
    end
  end
end

# trigger
NotifyThatWorkWasPublishedJob.perform_later(work_id: work.id)
```

The issue here is that we are keeping the execution within the same
thread. That means if the backend logic will waste time on retry several
seconds this will increase the actual execution of the entire Job.

In other words our Job may time out.


### Requeue the job

Upon expected fail we will requeue the Job and pass attempt count as
an argument:


```ruby
# app/jobs/new_work_published_job.rb
class NotifyThatWorkWasPublishedJob < ActiveJob::Base
  WorkNotFound = Class.new(StandardError)
  WorkNotFoundEvenAfterRetry = Class.new(StandardError)

  queue_as :notifications

  def perform(work_id:, attempt: 0)
    attempt = attempt + 1
    work = Work.find_by(id: work_id) || raise(WorkNotFound)

    # ...some logic that will send Email, Push notification etc.
  rescue WorkNotFound
    if try < 4
      # optionally you can add `sleep 1` here to prolong wait period. However it's not recommended as that 1 second delay will hold up your BG job thread.
      self.class.perform_later(work_id: work_id, try: try)
    else
      raise(WorkNotFoundEvenAfterRetry)
    end
  end
end

# trigger
NotifyThatWorkWasPublishedJob.perform_later(work_id: work.id)
```




### ActiveJob retry

**recommended  solution**


```ruby
# app/jobs/new_work_published_job.rb
class NotifyThatWorkWasPublishedJob < ActiveJob::Base
  WorkNotFound = Class.new(StandardError)

  retry_on WorkNotFound
  queue_as :notifications

  def perform(work_id:)
    work = Work.find_by(id: work_id) || raise(WorkNotFound)

    # ...some logic that will send Email, Push notification etc.
  end
end

# trigger
NotifyThatWorkWasPublishedJob.perform_later(work_id: work.id)
```


`retry_on` supports arguments such as `wait` time (default `3.seconds`), or `attempts`(default `5`), even `queue` and `priority`.

```ruby
retry_on WorkNotFound, wait: 3.seconds, attempts: 5
```

* <https://guides.rubyonrails.org/active_job_basics.html#retrying-or-discarding-failed-jobs>
* <https://api.rubyonrails.org/v6.0.0/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on>


> Thank you [jrochkind](https://www.reddit.com/r/ruby/comments/dgifxy/retry_activejob_sidekiq_on_exception/f3dc097/) for recommending this solution

### Let it fail. Let Sidekiq do the retry

In case where you use ActiveJob with Sidekiq default behavior of Sidekiq
is that it will requeue failed job and retry it later.

Now this is nothing new we described this in the top of the article and
we said that we don't want this as error monitoring tool like Airbrake
will be hammered with exceptions messages.

Now there is a way how to silence Airbrake errors when they are Sidekiq
retried:


```ruby
# config/initializers/airbrake.rb
require 'airbrake/sidekiq'
# ...
# ...
# ...

Airbrake.add_filter(Airbrake::Sidekiq::RetryableJobsFilter.new)
```


From <https://github.com/airbrake/airbrake#airbrakesidekiqretryablejobsfilter>:

> By default, Airbrake notifies of all errors, including reoccurring errors during a retry attempt. To filter out these errors and only get notified when Sidekiq has exhausted its retries you can add the RetryableJobsFilter:



> thank you [mperham](https://www.reddit.com/r/ruby/comments/dgifxy/retry_activejob_sidekiq_on_exception/) for suggestion

Now I see two issues with this:

First of all I believe this is a global solution so there is no way how
to filter certain sidekiq exceptions after different number of retries.
For example if exception `CouldNotSendMailingListEmailJobFaild` it's fine to
get notifield by Airbrake in couple of hours but if you are dealing with
exception such as `BankTransactionBetweenAccountsJobFailed` you better
get notified by Airbrake within seconds !

I didn't tried this Airbrake::Sidekiq::RetryableJobsFilter in my application so please correct me if I'm
wrong.

But even if I'm wrong with  configuration options of this Airbrake
filter you will still have the issue that in Sidekiq jobs may get
retried in couple of minutes/hours/days (unless you step in to the UI and
you trigger there retry manually)

<https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry>

So in many smaller applications this solution may be fine enough option.
But if you are dealing with application where you want to have closer
grip of the retry process I don't recommend this approach


### Go pro

I know Sidekiq pro provides extra features so maybe a thing to consider is
to pay a license :) 

### Discussion


* <https://www.reddit.com/r/ruby/comments/dgifxy/retry_activejob_sidekiq_on_exception/>
