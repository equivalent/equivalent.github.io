---
layout: til_post
title:  "Rails PostgreSQL find by nested JSON / JSONb field"
categories: til
disq_id: til-84
---


Imaging Rails model `SubscriptionsHistory` with **json** field `data`
that has nested JSON: `subscription.id`

So `SubscriptionsHistory.attributes` would return:

```
{"id"=>654321,
 "data"=>
  {"subscription"=>
    {"id"=>"169lTASJ5wfsY3y3u",
     "other_field"=>"xxx"},
   "other_field"=> { ....}
 "created_at"=>Mon, 14 Dec 2020 02:00:19 UTC +00:00,
 "updated_at"=>Mon, 14 Dec 2020 02:00:19 UTC +00:00}
```

so in order to find `subscription_history.data` where `subscription.id` is equal to `169lTASJ5wfsY3y3u`

```ruby
SubscriptionsHistory.where("data->'subscription'->>'id' = ?", '169lTASJ5wfsY3y3u')
```

* <https://makandracards.com/makandra/37851-how-to-query-postgresql-s-json-fields-from-rails>
