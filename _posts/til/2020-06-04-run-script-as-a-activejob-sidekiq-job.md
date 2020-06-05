---
layout: til_post
title:  "Run Rails script as an ActiveJob job"
categories: til
disq_id: til-75
---

> ...or how to run Ruby on Rails script as a Sidekiq job, delayed_job job, ...

How do you run scripts on your production Ruby on Rails server ?

In most small/medium projects it's enough just to `ssh`  to a server and
run `rake` task with  the script.

> or just do `heroku run rake mytask` if you are on Heroku

But :

* What if you have loadbalanced environment where the node/vm/container running the long running script may get removed?
* What if your DevOps dude configured the `ssh` timeout to be just couple of minutes ?
* What if your DevOps configured your stack so that you are not able to `ssh` to production in first place ?

And even if none of the above apply to you: what if you have couple of
hundred thousand records that the script needs to update couple of hours? Will you wait till the `rake`
task finish ?

## Solution

Create a [ActiveJob](https://guides.rubyonrails.org/active_job_basics.html) job that will process individual records (`FxSingleJob` in an example bellow).
In order to call it introduce another ActiveJob job (`FxJob` in an example bellow)  that will enqueue those records
in the first place.

This way you will just ssh to server, run `bin/rails c` and run `FxJob.perform_later` (or create rake task that will trigger it as `perform_later`)

Point is that you want to exist soon as possible from the `ssh`
connection so that Worker takes over and do a chunk of a script as a job

> Don't forget that you want to keep your ActiveJobs (background jobs) small so they execute and exit as soon as possible.

In case the queuing job (`FxJob`) dies prematurely  we want to be aware what
records were enqueued / processed. There are couple of ways to do it but the easiest
is just to introduce a db field that gets marked as processed.


## Example

step 1: Introduce a field that would indicate what records were processed

```bash
bin/rails generate migration add_fx_script_processed_field_to_works
```

```ruby
#db/migrations/xxxxxxx.rb
class AddColumnPublishedMigrationFinished < ActiveRecord::Migration[6.0]
  def change
    add_column :works, :fx_script_processed, :boolean, default: false
  end
end
```

```bash
rake db:migrate
```


step 2: ActiveJob script

```ruby
# app/jobs/fx_job.rb
class FxJob < ActiveJob::Base
  queue_as :script # don't forget to introduce new queues if you are  using Sidekiq

  def perform
    Work.where(fx_script_processed: false).find_each do |work|
      FxSingleJob.pefrom_later(work_id: work.id)
    end
  end
end
```


```ruby
# app/jobs/fx_single_job.rb
class FxSingleJob < ActiveJob::Base
  queue_as :script_single

  def perform(work_id: )
    work = Work.find_by!(id: work_id)
    # ...
    work.do_some_script_logic
    # ...
    work.fx_script_processed = true
    work.save!
  end
end
```

If all goes ok after there are no ActiveJobs left to be process that means all your records are processed.  You can be
sure about that by checking `Work.where(fx_script_processed: false).count == 0`

> e.g. you can check [Sidekiq dashboard](https://github.com/mperham/sidekiq/wiki/Monitoring#web-ui)) 

If you discover the main `FxJob` job died prematurely you can just
retrigger it  with `FxJob.perform_now`. You don't have to be worried
that it will reprocess same records again due to `Work.where(fx_script_processed: false)` condition


### Lazy solution example

It may feel like an overkill but this is the best way how to ensure your
data was processed (if it's important data)

But in lot of cases you don't need to introduce extra db field (as you
are able to detect it from the DB results.

Also there is no particular reason to introduce separate job file if you
are able to place all of the logic in one ActiveJob file. It really depends how
comfortable  you are that you will not screw it up.

In 90% of cases this is more than enough:


```ruby
class LazyFxJob < ActiveJob::Base
  queue_as :script

  def perform(work_id: nil)
    if work_id.present?
      work = Work.find_by!(id: work_id)
      work.make_public
      work.save!
    else
      # Depending on your logic it can be any scope. You don't need to process all records
      #
      #    Work.where(some_condition: false).find_each do |w|
      #    Work.order(id: :desc).find_each do |w|
      #    ...
      #
      Work.where(published: false).find_each do |w|
        LazyFxJob.perform_later(work_id: w.id)
      end
    end
  end
end
```


...and trigger `LazyFxJob.perform_later`



### Paginated script scenario

Sometimes you are dealing with a scenario where you are not able to
trigger multiple jobs at the same time.

For example some APIs limit how many requests you can do per minute.
If you enqueue multiple jobs at the same time hitting the API you will
definitely kill that limit.

At the same time you want to exit/finish your jobs as soon as possible (so
they don't time out)

Way ho to get around this is  to trigger a job that will enqueue itself after finishing
single call:


```ruby
class SyncOutdatedProductDescriptionsJob < ActiveJob::Base
  queue_as :script

  def perform(limit: 3)
    products = Product
      .where("last_automated_description_update_at < ?", Date.today)
      .sample(limit) # random items

    if products.any?
      products.each do |product|
        process_product(product)
      end

      # we are requeueing the job to process another set
      SyncOutdatedProductDescriptionsJob.perform_later(limit: limit)
    else
      # All is finished ^_^
      # ...maybe send email to Admin that script finished ?
    end
  end

  private

  def process_product(product)
    url = product.external_description_url
    externaal_description = HTTParty.get(url)

    product.description = externaal_description
    product.last_automated_description_update_at = Time.now
    praduct.save!
  end
end
```

trigger with `SyncOutdatedProductDescriptionsJob.perform_later`

Script above will process 3 unprocessed products (fetching their external API
description and saving it) and requeue itself so it process another 3
products.

If you discover the scripts are killing your API limit you can decrease
how many items it will process in one go by `SyncOutdatedProductDescriptionsJob.perform_later(limit: 1)`

Or if it's too slow `SyncOutdatedProductDescriptionsJob.perform_later(limit: 9)`

Yes it's not ideal as if your job dies, other will not get queued and
therefore not processed. But again it can be retriggered without fear we
will process already processed items.

## Bonus - nice ActiveJob tricks

### retry_on

Thing to remember is that by using ActiveJob `perform_later` we are
dealing with asynchronous calls.

There are cases when exceptions are raised in ActiveJob just because
resource is not ready (E.g. Redis is faster than PostgreSQL so you may
end up with calling Sidekiq job or record.id  before SQL transaction finish writing the record)

You can easily tell the jobs to re-execute on known exceptions

```ruby
class SyncOutdatedMailchimpMembersJob < ActiveJob::Base
  queue_as :whatever
  retry_on UserNotReadyYet

  def perform(user_id: )
    user = User.find_by!(id: user_id)

    user.check_if_user_ready || raise(UserNotReadyYet)
    # ...
  end
end
```

I have entire TIL note on this <https://blog.eq8.eu/til/retry-active-job-sidekiq-when-exception.html> if you want to learn more

## Discussion


