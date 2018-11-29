---
layout: til_post
title:  "Tell ActiveJob to perform_later as perform_now in Test or Spec"
categories: til
disq_id: til-30
redirect_from: 
  - "/tils/30"
  - "/tils/30-tell-activejob-to-perform_later-as-perform_now-in-test-or-spec"
---

Rails[ActiveJob](http://edgeguides.rubyonrails.org/active_job_basics.html)

Let say you have `perform_later` job that is calling another
`perform_later` job and you want to test the end result.

```ruby
class Job1 < AciveJob::Base
  def perform(foo:)
    bar = "#{foo}bar"
    Job2.perform_late(bar: bar)
  end
end

class Job2 < AciveJob::Base
  def perform(bar:)
    Httparty.post("http://myserver", bar)
  end
end

require 'spec_helper'
RSpec.describe Job1 do
  it do
    expect(Httparty).to receive(:post).with("http://myserver", "mybar")
    Job1.new.perform("my")
  end
end
```

Even if you set the queuing adapter to be`ActiveJob::Base.queue_adapter = :test`
the second call may not be executed as ActiveJob is holding second call
for assertion tests

> Global setting solution is described at the bottom section of this article


What you can do is wrap the call in build in `ActiveJob::TestHelper` module
method `perform_enqueued_jobs` block:

* <http://api.rubyonrails.org/v4.2/classes/ActiveJob/TestHelper.html#method-i-perform_enqueued_jobs>

```ruby
require 'spec_helper'
RSpec.describe Job1 do
  include ActiveJob::TestHelper

  it do
    perform_enqueued_jobs do
      Job1.new.perform("my")
    end
  end
end
```

Or if you don't want to polute your tests with unecesarry methods:


```ruby
require 'spec_helper'

module MyTest
  class Jobs
    include ActiveJob::TestHelper
  end

  def self.jobs
    @jobs ||= Jobs.new
  end
end

RSpec.describe Job1 do
  it do
    MyTest.jobs.perform_enqueued_jobs do
      Job1.new.perform("my")
    end
  end
end
```

### Global setting

This will ensure all the tests will execute Jobs imidietly (not queue)

In `config/enviroments/test.rb` :


```ruby
# config/enviroments/test.rb

Rails.application.configure do
  # ...
  config.active_job.queue_adapter = :inline
  # ...
end
```

... or

```
# spec/rails_helper.rb or config/enviroments/test.rb
Rails.application.config.active_job.queue_adapter = :inline
```

if you want to revert to original setup where you queue jobs:

```ruby
Rails.application.config.active_job.queue_adapter = :async
# or
Rails.application.config.active_job.queue_adapter = :sidekiq
```

To lern more about [Active Job adapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)
