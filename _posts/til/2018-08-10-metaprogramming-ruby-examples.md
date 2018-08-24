---
layout: til_post
title:  "Metaprogramming Ruby cheatcheat"
categories: til
disq_id: til-52
---

This is a collection of Metaprogramming Ruby copy-paste examples.

> Metaprogramming is gentle art of writing code that defines/writes other code.

Article was published 2018-08-23 and examples were tried under Ruby
version 2.5.1

[![Advisory](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/advisory.jpg)](https://youtu.be/8EQbWVcG4sM)

Please be aware that metaprogramming is handy but also dangerous.
Right amount may make your library/gem awesome but overuse may lead your project hard to understand or debug.

### Define method

`define_method` is usually used when you want to dynamically define methods. E.g.:

```ruby
class Account
  attr_accessor :state

 (1..99).each do |i|
 	define_method("credit_#{i}".to_sym) do
 		self.state = state + i
 	end

 	define_method("debit_#{i}".to_sym) do
 		self.state = state - i
 	end
 end

  def initialize(state)
    @state = state
  end
end

account = Account.new(20)
account.credit_31
account.state # => 51
account.debit_45
account.state # => 6
```

Methods will also appear on the public_methods list:

```ruby
account.public_methods(false)
# [ ... , :credit_83, :debit_83, :credit_84, :debit_84, ...]
account.respond_to?(:debit_19)
# => true
method = account.public_method(:debit_19)
# => #<Method: Account#debit_19> 
```

#### Variations of the `define_method`:

> (Based on [this SO answer](https://stackoverflow.com/questions/89650/how-do-you-pass-arguments-to-define-method/11098487#11098487))

With arguments

```ruby
class Bar
  define_method(:foo) do |arg1, arg2|
    arg1 + arg2
  end
end

a = Bar.new
a.foo
#=> ArgumentError (wrong number of arguments (given 0, expected 2))
a.foo 1, 2
# => 3
```

Optional argument

```ruby
class Bar
  define_method(:foo) do |arg=nil|
    arg
  end
end

a = Bar.new
a.foo
#=> nil
a.foo 1
# => 1
```

As many arguments as you want

```ruby
class Bar
  define_method(:foo) do |*arg|
    arg
  end
end

a = Bar.new
a.foo
#=> []
a.foo 1
# => [1]
a.foo 1, 2 , 'AAA'
# => [1, 2, 'AAA']
```

Keyword arguments:

```ruby
class Bar
  define_method(:foo) do |option1: 'default value', option2: nil|
    "#{option1} #{option2}"
  end
end

bar = Bar.new
bar.foo option2: 'hi'
# => "default value hi"
bar.foo option2: 'hi',option1: 'ahoj'
# => "ahoj hi"
```

As many keyword arguments as you want:

```ruby
class Bar
  define_method(:foo) do |**keyword_args|
    keyword_args
  end
end

bar = Bar.new
bar.foo option1: 'hi', option2: 'ahoj', option3: 'ola'
# => {:option1=>"hi", :option2=>"ahoj", :option3=>"ola"}
```

All of them

```ruby
class Bar
  define_method(:foo) do |variable1, variable2, *arg, **keyword_args, &block|
    p variable1
    p variable2
    p arg
    p keyword_args
    p block.call
  end
end

bar = Bar.new
bar.foo :one, 'two', :three, 4, 5, foo: 'bar', car: 'dar' do
  'six'
end

## will print:
:one
"two"
[:three, 4, 5]
{ foo: "bar", car: "dar" }
'six'
```

### method missing

Simmilar to  `define_method`, `method_missing` is usually used when you want to dynamically define methods. E.g.:

```ruby
class Account
  attr_accessor :state

  def initialize(state)
    @state = state
  end

  def method_missing(method_name, *args, **keyword_args, &block)
    if result = method_name.match(%r(\Adebit_\d*\z))
      self.state = state - extract_number(result)
    elsif result = method_name.match(%r(\Acredit_\d*\z))
      self.state = state + extract_number(result)
    else
      super
    end
  end

  private

  def extract_number(matched_result)
    matched_result[0].split('_')[1].to_i
  end
end

account = Account.new(20)
account.debit_12
account.state # => 8
account.credit_999
account.state # => 1007
```

Reason why  to  `define_method` might be a better choice doh is that
method missing dosn't register them to `public_methods`:

```ruby
account.public_methods(false)
# =>  [:state=, :state, :method_missing]
```

Therfore you cannot do method operations on it:

```ruby
account.respond_to?(:debit_19)
# => false
method = account.public_method(:debit_19)
# => NameError (undefined method `debit_19' for class `Account')
```

Argument passing to `method_missing` apply similar way as for `define_method`:

```ruby
  def method_missing(method_name, *args, **keyword_args, &block)
    # ...
  end
```

### Include / Extend (modules & mixins)

```ruby
module Debit
  module ClassMethods
    def is_awesome?
      "is awesome"
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def transaction(amount)
    self.state = state - amount
  end
end

class Account
  include Debit

  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

Account.is_awesome?
# => "is Awesome"
account = Account.new(20)
account.state # => 20
account.transaction(4)
account.state # => 16
```

Ruby on Rails framework introduced [ActiveSupport::Concerns](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
that will make this even easier:

```ruby
# require 'active_support/concern'

module Debit
  extend ActiveSupport::Concern

  included do
    # scope :approved, -> { where(approved: true) }
  end

  class_methods do
    def is_awesome?
      "is awesome"
    end
  end

  def transaction(amount)
    self.state = state - amount
  end
end

class Account
  include Debit

  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

Account.is_awesome?
# => "is Awesome"
account = Account.new(20)
account.state # => 20
account.transaction(4)
account.state # => 16
```

You may want to use extend to widen your class methods:

```ruby
module Bar
  def bar
    "bar"
  end
end

class Foo
  extend Bar
end

Foo.bar  # => "bar"
```

But you may use same module for both extend and include

```ruby
module Bar
  extend self  # `self` in this case is `Bar`, therefore you are doing equivalent of `extend Bar`

  def bar
    "bar"
  end
end

class Foo
  include Bar
end

Bar.bar      # => "bar"
Foo.new.bar  # => "bar"
```

### Eval

```ruby
class Account
  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

Account.instance_eval do
  def is_awesome?
    "it is truly awesome"
  end
end

Account.class_eval do
  def debit(amount)
    self.state = state - amount
  end
end

Account.is_awesome?
# => "it is truly awesome"
account = Account.new(20)
account.debit(3)
account.state
# => 17


account.instance_eval do
  def credit(amount)
    self.state = state + amount
  end
end

account.credit(35)
account.state
# => 52

# BUT ! If I initialize new Account instance, this method will not be there
account = Account.new(6)
account.credit(15)
# NoMethodError (undefined method `credit' for #<Account:0x0000000000d259b0 @state=6>)

# `instance_eval` is simmilar of doing:
def account.other_version_of_credit(amount)
  self.state = state + amount
end

account.other_version_of_credit(5)
# => 11

def Account.other_awesome
  "still awesome"
end

Account.other_awesome
# => "still awesome"
```

Now there also possibility to use kernel [eval](https://apidock.com/ruby/Kernel/eval)
but I highly recommend to avoid it (security) unless you really know what you are
doing.

```ruby
meaning_of_life = 42
eval("def answer; #{meaning_of_life}; end")

answer
# => 42
```

> you will be able to achieve same results with other technique
> mentioned in this post

### Singleton Class object extend

Inspired by article by [Benedikt Deicke - Changing the Way Ruby Creates Objects](https://blog.appsignal.com/2018/08/07/ruby-magic-changing-the-way-ruby-creates-objects.html)


```ruby
module Debit
  def transaction(amount)
    self.state = state - amount
  end
end

module Credit
  def transaction(amount)
    self.state = state + amount
  end
end

class Account
  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

account = Account.new(20)
account.state # => 20
account.singleton_class.include(Debit)
account.transaction(4)
account.state # => 16

account.singleton_class.include(Credit)
account.transaction(5)
account.state # => 21
```

### Method re-binding

Be aware! This is still experimental feature in Ruby and too fast.

I've already wrote article about this [Method re-binding in Ruby](https://blog.eq8.eu/til/method-binding-in-ruby.html) if you want to learn more.

```ruby
class Account
  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

module Debit
  def transaction(amount)
    self.state = state - amount
  end
end

module Credit
  def transaction(amount)
    self.state = state + amount
  end
end

account = Account.new(100)
account.state                       # => 100
puts account.public_methods(false)  # => [:state, :state=]

debit = Debit.instance_method(:transaction)
credit = Credit.instance_method(:transaction)

# Lets do debit transactions
transaction = debit.bind(account)
transaction.call(6)

account.state                       # => 94
account.public_methods(false)  # => [:state, :state=]

# Lets do credit transactions
transaction = credit.bind(account)
transaction.call(15)

account.state                  # => 109
account.public_methods(false)  # => [:state, :state=]
```

### Discussion

I'll try to add more in next couple of days as they pop to my mind. But
if I forgot to add your favorite one pls ping me a comment

* <https://www.reddit.com/r/ruby/comments/99lcsu/metaprogramming_ruby_cheatcheat/>
* <http://www.rubyflow.com/p/cr5ze7-metaprogramming-ruby-cheatcheat>

