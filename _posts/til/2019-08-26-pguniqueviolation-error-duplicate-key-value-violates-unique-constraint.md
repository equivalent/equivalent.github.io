---
layout: til_post
title:  "PG::UniqueViolation: ERROR: duplicate key value violates unique constraint"
categories: til
disq_id: til-66
---

```ruby
ActiveRecord::RecordNotUnique PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "table_names_pkey" DETAIL: Key (id)=(70) already exists. : INSERT INTO "table_names"
```

Moste of the time when this error happen you are just trying to save
some value over already existing unique value in Ruby on Rails database
like PostgreSQL

But some time this happens when database goes out of wack (e.g. you
deleted all the records but forgot to resent constraints in Staging
database)

In that case this is easy fix:

```ruby
ActiveRecord::Base.connection.tables.each do |table_name|
  ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
end
```



source:
<https://stackoverflow.com/questions/47577532/why-pguniqueviolation-error-duplicate-key-value-violates-unique-constraint?rq=1>
