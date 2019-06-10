---
layout: til_post
title:  "Rails sequence error on postgresql db"
categories: til
disq_id: til-65
---


Recently my staging DB start throwing `ActiveRecord::RecordNotUnique PG::UniqueViolation: ERROR: duplicate key value violates unique constraint` error.

I don't fully understand how the error happened (maybe it was because I
trigger copy production to staging DB script) but result was that postgresql database
went out of sync on information: "was the last ID inserted" 

> or maybe that's Rails to blame [source](https://dba.stackexchange.com/questions/46125/why-does-postgres-generate-an-already-used-pk-value)

That means that last ID was `358878` but for some reason Rails or
Postgres thinks it's `358871` 


Example error

```
ActiveRecord::RecordNotUnique PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "puppies_pkey" DETAIL: Key (id)=(358871) already exists. : INSERT INTO "puppies" ("created_at", "updated_at", "public_uid") VALUES ($1, $2, $3) RETURNING "id"
```

Anyway I acknowledge I don't fully understand this error but here is
solution

### Solution

based on [this SO question](https://stackoverflow.com/questions/28723505/rails-reset-all-postgres-sequences)


```ruby
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end
```

Now newly created records should have the proper sequence
