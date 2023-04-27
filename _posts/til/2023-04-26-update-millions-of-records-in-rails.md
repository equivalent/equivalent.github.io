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

For simplicity `MyService` will just downcase `city` name & `state` for entire batch of Address objects.

> Yes this can be done with a single SQL query (If you can afford to lock entire table for couple of minutes)
> Please consider  **this is just an example** and the real script where you want to use this will be more complex  with  **business logic code directly involved**.

In this example I'm using gem [activerecord-import](https://github.com/zdennis/activerecord-import) in order to update/insert multiple records with *one SQL query* (including validations). Project I work for already uses this gem so it's well tested solution for our use case.

**However** Vanilla Rails has [.upsert_all](https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all) that serves similar purpose and you can achieve the same result with it.
Reason why the article is not using `.upsert_all` is because I didn't used it in production yet  so I'm not going to recommend something I didn't truly use 😉. But it's worth checking it out.

> Note `upsert` SQL operation is pretty much "insert or update" = is slower than `update` operation where you already know the IDs and you don't expect conflict (Thank you [Seuros](https://www.reddit.com/r/ruby/comments/12zmxkb/comment/jhtp201/?utm_source=share&utm_medium=web2x&context=3) for pointing this out).


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

Because we ([PostPilot](https://www.postpilot.com/)) are dealing with several hundred millions of records it's not easy to get those numbers right. You need to schedule few thousand record samples and **monitor** how well/bad will your worker perform

> e.g in Heroku monitor your worker dyno Memory usage, in tool like NewRelic or AppSignal monitor DB Load & I/O Operations, Monitor errors, In Sidekiq Web UI monitor number of jobs in queue and how long the job takes to finish (aim for "finish fast" jobs - up to 2 minutes was my goal)

Maybe your worker will consume all the memory and you need to schedule smaller batches. Maybe you need to increase memory on the underlying VM running your Sidekiq workers

> For example Heroku Standard 1x Dyno has only 512MB, maybe increase it to Standard 2x Dyno (1GB could be enough), or in some cases it make sense to go Performance-M Dyno with 2,5GB. More in [heroku dynos](https://devcenter.heroku.com/articles/dyno-types) and [common dyno type issues](https://judoscale.com/guides/how-many-dynos)

Maybe your worker will be underutilized and therefore you can increase `worker_batch_size` or **number of threads for your Sidekiq worker**

> just be mindfull on how many active connections your PosgreSQL DB can handle.
For example Heroku's Standard 7 has 500 [Connection Limit](https://elements.heroku.com/addons/heroku-postgresql#pricing). For example 30 dyno with 5 threads == 150 DB connections + you still need connections for rest of the app (webserver, other workers)

Try tweeking those numbers and for each schedule a sample of couple thousand of records.

Once you got this right you can go wild and increas number of Sidekiq workers (for example have 30, 40, 50 Heroku dynos for your worker)

Recommendation here is not to schedule all 500 M records. But try to schedule 100K see how it goes (monitor), then 1M (monitor), then 10M, 100M, ...

### Implement Killswitch

You are enqueuing a LOT of jobs. Be sure you have a way to kill those jobs if something goes wrong.

#### Option 1 - Separate worker for script jobs

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


#### Option 2 - Killswitch flag

If Option 1 is not possible for you, you can implement a killswitch flag in your worker code.

If you use something like [Flipper](https://github.com/jnunemaker/flipper) you can exit a job if a flag is set, etc...


```ruby
# app/workers/update_addresses_worker.rb
class UpdateAddressesWorker
  # ...

  def perform(min_id, max_id, batch_size = 1_000)
    return if Flipper[:killswitch].enabled? # optional
    # ...or `return if ENV['KILLSWITCH'].present?`
    # ...or just deploy updated worker with `return` on beginning of this method

    #...
```

> e.g. in Heroku when you change ENV variable dyno will reinstantiate . So you can set e.g. `KILLSWITCH` ENV variable.


### How long did it take?

The service had a quite fast business logic code resulting in constructing a SQL that would update couple of fields on a table.

The process of probing different batch sizes & Sidekiq thread numbers with couple of thousands/millions records took about 5 hours. We ended up with 5 threads on 40 Standard 2x Heroku dynos. 

Then the actual run of the script with rest of the  half a billion records was finished by the morning (I've run it like 11 PM, I've checked 7AM next day and all was finished).

> We ([PostPilot](https://www.postpilot.com/)) use [Judoscale](https://elements.heroku.com/addons/judoscale) so the dyno number was back to 0 by the morning.

Again this is very specific to our setup. Your setup will be different. You need to monitor and adjust accordingly.
Also our DB was not under heavy load during the night. If you have a lot of usage on your DB you need to be more careful.


### Credits

Full credit for this solution goes to  [Matt Bertino](https://github.com/mbbertino) who taught me this. He is a true PostgeSQL & Ruby on Rails wizard 🧙‍♂️.

Do you want to see what we do? Check us out at [postpilot.com](https://www.postpilot.com/)

### Source

* <https://github.com/zdennis/activerecord-import#introduction>
* <https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all>
* <https://apidock.com/rails/v6.0.0/ActiveRecord/Persistence/ClassMethods/upsert_all>
* <https://blog.kiprosh.com/rails-7-adds-new-options-to-upsert_all/>
* <https://judoscale.com/guides/how-many-dynos>


### Discussion

* [Reddit r/rubyonrails](https://www.reddit.com/r/rubyonrails/comments/12zo2pp/update_millions_of_records_in_rails_fast/)
* [Reddit r/ruby](https://www.reddit.com/r/ruby/comments/12zmxkb/update_millionsbillions_of_records_in_rails/)
* [Reddit r/rails](https://www.reddit.com/r/rails/comments/12zmw17/update_millionsbillions_of_records_in_rails/)
* <https://news.ycombinator.com/item?id=35717344>