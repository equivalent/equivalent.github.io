---
layout: til_post
title:  "Metaprogramming Ruby examples"
categories: til
disq_id: til-52
---

This is a collection of Metaprogramming Ruby copy-paste examples.

> article was wrote 2018-08-22 and examples were tried under Ruby
> version 2.5.1

I'll be updating this article with more examples over the next couple of
days.

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
acount.respond_to?(:debit_19)
# => true
method = acount.public_method(:debit_19)
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
{ foo: 'bar', car: 'dar' }
[:three, 4, 5]
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

```
acount.respond_to?(:debit_19)
# => false
method = acount.public_method(:debit_19)
# => NameError (undefined method `debit_19' for class `Account')
```

Argument passing to `method_missing` apply similar way as for `define_method`:

```ruby
  def method_missing(method_name, *args, **keyword_args, &block)
    # ...
  end
```

To be continued ...
