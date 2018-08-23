---
layout: til_post
title:  "Method binding in Ruby"
categories: til
disq_id: til-42
---


How to do method binding (or re-binding) in Ruby

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

So when you think about it, we manage to decorate the object with a
method, called some logic that changed the state and then we were able
to work with the original object (without that method)

> Note! This is still quite slow feature in Ruby. I personally wouldn't
> use it in a production code. But it's cool that something like this
> exist.


Unlike `include`, `extend`, inheritance this is reversable => you can
work with original object without that logic. With include/extend once
you go that way you cannot come back:

```ruby
module Foo
  def foo
    123
  end
end

a = Object.new
b = a
a.extend(Foo)
a.foo   # => 123
b.foo   # => 123
```

> Well yeah you could, like with [Refinements](http://ruby-doc.org/core-2.0.0/doc/syntax/refinements_rdoc.html) but that's not my point. You should be able to access the original (undecorated) object.


And although you can do similar transformations with decorator objects (e.g. like `SimpleDecorator`)
the point is that you have to define class where you pass object in order to do
transformation. You are not directly injecting / removing functions from
object (bind/unbind).

### Sources

* <https://www.rubytapas.com/2013/05/01/episode-091-ruby-2-0-rebinding-methods/>

### Related articles

* [Ruby metaprogramming examples](https://blog.eq8.eu/til/metaprogramming-ruby-examples.html)

### Discussion to this article:

* <https://www.reddit.com/r/ruby/comments/80cu8y/method_binding_in_ruby/>


