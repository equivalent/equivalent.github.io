---
title:  "Rollback Rails transaction and rescue error to display it"
categories: til
disq_id: til-81
layout: til_post
---


This is fine

```ruby
record = MyModel.last
error_for_user = nil

begin
  ActiveRecord::Base.transaction do
    # ...
    record.save!
  end
rescue ActiveRecord::RecordInvalid => e
  # do something with exception here
  error_for_user = "Sorry your transaction failed. Reason: #{e}"
end

puts error_for_user || "Success"
```

> [source](https://stackoverflow.com/questions/24218477/how-to-rescue-model-transaction-and-show-the-user-an-error), [source2](https://medium.com/@kristenrogers.kr75/rails-transactions-the-complete-guide-7b5c00c604fc), [source3](https://stackoverflow.com/questions/1937795/error-handling-in-activerecord-transactions)


This is ok as well, but pls realize `StandardError` is base for many errors that may happen not related to valid record

```ruby
record = MyModel.last
error_for_user = nil

begin
  ActiveRecord::Base.transaction do
    # ...
    record.save!
  end
rescue StandardError => e
  # do something with exception here
  error_for_user = "Sorry your transaction failed. Reason: #{e}"
end

puts error_for_user || "Success"
```

So much better would be if you define your own error classes and rescue
those like this:


```ruby
MyErrors = Class.new(StandardError)
MySpecificError = Class.new(MySpecificError)

record = MyModel.last
error_for_user = nil

begin
  ActiveRecord::Base.transaction do
    # ...
    record.save!
    raise MySpecificError if record.has_some_issue?
  end
rescue ActiveRecord::RecordInvalid, MyErrors => e
  # do something with exception here
  error_for_user = "Sorry your transaction failed. Reason: #{e}"
end

puts error_for_user || "Success"
```


#### wrong:

Following code is wrong!

```ruby
record = MyModel.last
error_for_user = nil


ActiveRecord::Base.transaction do
  begin
    # ...
    record.save!
  rescue ActiveRecord::StatementInvalid => e # DON'T DO THIS !
    error_for_user = "Sorry your transaction failed. Reason: #{e}"
  end
end

puts error_for_user || "Success"
```

Why is it wrong ? According to  [Active Record Transactions docs](https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html): 
> one should not catch `ActiveRecord::StatementInvalid` exceptions inside a transaction block. `ActiveRecord::StatementInvalid` exceptions indicate that an error occurred at the database level


Following code is also wrong!

```ruby
record = MyModel.last
error_for_user = nil


ActiveRecord::Base.transaction do
  begin
    # ...
    record.save!
  rescue StandardError => e # DON'T DO THIS !
    error_for_user = "Sorry your transaction failed. Reason: #{e}"
  end
end

puts error_for_user || "Success"
```

Because `ActiveRecord::StatementInvalid < ActiveRecord::ActiveRecordError < StandardError` Therefore to rescue `StandardError` you rescue any children classes including `ActiveRecord::StatementInvalid`   same reason as described before


## Triggering rollback manually / Abort transaction

this is fine:

```ruby
def add_bonus(tomas)
  ActiveRecord::Base.transaction do
    raise ActiveRecord::Rollback if john.is_not_cool?
    tomas.update!(money: tomas.money + 100)
  end
end


begin
  add_bonus(tomas)
rescue ActiveRecord::Rollback => e
  puts "Sorry your transaction failed. Reason: #{e}"
end

```

> [source](https://www.honeybadger.io/blog/database-transactions-rails-activerecord/), [source2](https://www.honeybadger.io/blog/database-transactions-rails-activerecord/)

## More Rails Transaction notes


#### Different aliases

there is no difference between `#transaction`, `MyModel.transaction` and
`ActiveRecord::Base.transaction`. All 3 examples are the same:

```ruby
my_model = MyModel.last

my_model.transaction do
  # ...
  my_model.save!
end

MyModel.transaction do
  # ...
  my_model.save!
end

ActiveRecord::Base.transaction do
  # ...
  my_model.save!
end
```


#### Avoid nested transactions

Nested transactions are possible but really hard to get right
([docs](https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#module-ActiveRecord::Transactions::ClassMethods-label-Nested+transactions)). My
recommendation is to avoid them.

If you are ever in situation you need to use method with transaction
inside another method with transaction rewrite your code so that the transaction is optional. Example:


```ruby
def partial_update_user!(user:, name:, own_transaction: true)
  user.name = name
  user.initial = name.to_s[0]

  persist_logic = ->(u){ u.save! } # lambda

  if own_transaction
    ActiveRecord::Base.transaction do
      persist_logic.call(user)
    end
  else
    persist_logic.call(user)
  end
end


def full_user_update!(user:, name:, email:)
  email_identity = user.email_identity
  email_identity.email= email

  ActiveRecord::Base.transaction do
    partial_update_user!(user: user, name: name, own_transaction: false)
    email_identity.save!

    raise ActiveRecord::Rollback if user.is_not_cool?
  end
end


user = User.last

partial_update_user!(user: user, name: 'Tomas') # executed with 1 transaction

full_user_update!(user: user, name: 'Tomas', email: 'equivalent@eq8.eu') # executed with 1 transaction
```




Want better explanation ? Good guide is this article: <https://medium.com/@kristenrogers.kr75/rails-transactions-the-complete-guide-7b5c00c604fc>


### sources:

* <https://stackoverflow.com/questions/24218477/how-to-rescue-model-transaction-and-show-the-user-an-error>
* <https://stackoverflow.com/questions/1937795/error-handling-in-activerecord-transactions>
* <https://medium.com/@kristenrogers.kr75/rails-transactions-the-complete-guide-7b5c00c604fc>
* <https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html>
* <https://www.honeybadger.io/blog/database-transactions-rails-activerecord/>


### Discussion

<https://www.reddit.com/r/ruby/comments/k09ccr/rollback_rails_transaction_and_rescue_error_and/>
