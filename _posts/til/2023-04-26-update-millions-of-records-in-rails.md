---
layout: til_post
title:  "Update millions of records in Rails"
categories: til
disq_id: til-100
---


How to update half a billion entries on a PostgreSQL table with Ruby on Rails & [Sidekiq](https://github.com/sidekiq/sidekiq)


### Worker


```ruby
# app/workers/update_addresses_worker.rb
class UpdateAddressesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :manual

  def perform(min_id, max_id, batch_size = 1_000)
    Address
      .where(id: min_id..max_id)
      .in_batches(of: batch_size) do |address_batch|
        MyService.new.call(address_batch)
      end
  end
end
```

> note: my queue name is "_manual_" you can use "_default_" or whatever you use in your app.


### Service

For simplicity `MyService` will just downcase `city` name & `state` for entire batch of Address objects

In this example I'm using gem [activerecord-import](https://github.com/zdennis/activerecord-import) in order to update/insert multiple records with *one SQL query* (including validations).

> Vanilla Rails has [.upsert_all](https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all) that serves simmilar purpouse.
> Reason why I use `activerecord-import` instead is that the project I work for already uses this gem == well tested solution for our case.


```ruby
class MyService
  def call(address_batch)
    addresses = address_batch.map do |address|
      address.city.downcase!
      address.state.downcase!
      address
    end

    # `Model.import` is from activerecord-import gem
    ::Address.import(
      addresses,
      on_duplicate_key_update: {
        conflict_target: %i[id],
        validate: true,
        columns: [:city, :state]
      }
    )
  end
end
```


Notice [on_duplicate_key_update](https://github.com/zdennis/activerecord-import#duplicate-key-update) options which takes care of updates of `city` & `state` (columns) when `addresses` db row matching the `id` (conflict_target) already exist.

### How to schedule this

Once you deploy the worker code to prod run a `rails c` console in production env.

Now try scheduling the worker in small chunks like this:

```ruby
Address.in_batches(of: 1_000, start: 300_000_000, finish: 300_010_000) do |address_batch|
   min_id = address_batch.minimum(:id)
   max_id = address_batch.maximum(:id)
   worker_batch_size = 250
   puts "#{min_id} - #{max_id}  [#{worker_batch_size}]"
   UpdateAddressesWorker.perform_async(min_id, max_id, worker_batch_size)
end

# 300_000_000 - 300_002_000  [250]
# 300_002_001 - 300_004_029  [250]
# 300_004_030 - 300_006_567  [250]
# ...
```

### Figure out the best for you

Because we are dealing with several hundred millions of records it's not easy to get those numbers right. You need to schedule few thousand record samples and **monitor** how well/bad will your worker perform.

Maybe your worker will consume all the memmory and you need to schedule smaller batches. Maybe you need to increase memory on the underlying VM running your Sidekiq workers

> For example Heroku Standard 1x Dyno has only 512MB, maybe increase it to Standard 2x Dyno (1GB could be enough), or in some cases it make sense to go Performance-M Dyno with 2,5GB. More in [heroku dynos](https://devcenter.heroku.com/articles/dyno-types) and [common dyno type issues](https://judoscale.com/guides/how-many-dynos)

Maybe your worker will be underutilized and therefore you can increase `worker_batch_size` or **number of threads for your Sidekiq worker**

> just be mindfull on how many active connections your PosgreSQL DB can handle.
For example Heroku's Standard 7 has 500 [Connection Limit](https://elements.heroku.com/addons/heroku-postgresql#pricing). For example 30 dyno with 5 threads == 150 DB connections + you still need connections for rest of the app (webserver, other workers)

Try tweeking those numbers and for each schedule a sample of couple thousand of records.

Once you got this right you can go wild and increas number of Sidekiq workers (for example have 30, 40, 50 Heroku dynos for your worker)

Recommendation here is not to schedule all 500 M records. But try to schedule 100K see how it goes (monitor), then 1M (monitor), then 10M, 100M, ...

### Implement Killswitch

You are enqueuing a LOT of jobs. Be sure you have a way to kill those jobs if something goes wrong.

#### Killswitch flag

Exit a job if ENV variable is set or if you use [Flipper](https://github.com/jnunemaker/flipper) you can exit a job if a flag is set, etc...


```ruby
# app/workers/update_addresses_worker.rb
class UpdateAddressesWorker
  # ...

  def perform(min_id, max_id, batch_size = 1_000)
    return if ENV['KILLSWITCH'].present?    # optional
    return if Flipper[:killswitch].enabled? # optional
    
    #...
```

#### Separate worker for script jobs

You don't need to add any special killswitch code for exit a job.

We recommend to have separate Sidekiq worker dedicated to script jobs like this.
Benefit is that if something goes wrong you can just scale these worker VMs to 0 (or 0 worker dynos on Heroku) and just delete the enqued jobs from Sidekiq Web UI.

`cat config/manual_sidekiq.yml`

```
:concurrency: <%= (ENV['MANUAL_MAX_THREADS'] || 1).to_i %>
:queues:
  - [manual, 4]
```

> note: the "MANUAL_MAX_THREADS" ENV variable, you can use this to scale the number of threads for your Sidekiq worker that would be running this script jobs. For example if you have 30 dynos for this worker you can set this to 5 and you will have 150 threads running in parallel.



### Credits

Full credit for this solution goes to  [Matt Bertino](https://github.com/mbbertino) who taught me this. He is a true PostgeSQL & Ruby on Rails wizard 🧙‍♂️.

### Source

* <https://github.com/zdennis/activerecord-import#introduction>
* <https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all>
* <https://apidock.com/rails/v6.0.0/ActiveRecord/Persistence/ClassMethods/upsert_all>
* <https://blog.kiprosh.com/rails-7-adds-new-options-to-upsert_all/>
* <https://judoscale.com/guides/how-many-dynos>


332401330 - 332403402  [400]
332403403 - 332407591  [400]
332407592 - 332412157  [400]
332412158 - 332414157  [400]
