---
layout: til_post
title:  "Method binding in Ruby"
categories: til
disq_id: til-42
---


How to do method binding in Ruby

...or how to decorate object so that it can be undecorated:


```ruby
class Account
  attr_reader :state

  def initialize(state)
    @state = state
  end
end

module Debit
  def transaction(amount)
    @state = @state - amount
  end
end

module Credit
  def transaction(amount)
    @state = @state + amount
  end
end

account = Account.new(100)
account.state                       # => 100
puts account.public_methods(false)  # => [:state]


debit = Debit.instance_method(:transaction)
credit = Credit.instance_method(:transaction)


# Lets do debit transactions
transaction = debit.bind(account)
transaction.call(3)
transaction.call(3)

account.state                       # => 94
puts account.public_methods(false)  # => [:state]
puts account.public_methods(false)  # => [:state]


# Lets do credit transactions
transaction = credit.bind(account)
transaction.call(7)
transaction.call(7)

puts account.state                  # => 108
puts account.public_methods(false)  # => [:state]

```

> Note! this is still experimental feature in Ruby and too fast.

