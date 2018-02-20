---
layout: til_post
title:  "How to delegate methods in Rails as private"
categories: til
disq_id: til-40
---


### Rails before version 5.2


```ruby
class Foo
  delegate(:public_x, :public_y, :to => :foo)

  private
  private *delegate(:foo, :bar, :to => :baz)

  def baz
    Baz.new
  end
end
```

* public methods will be: `public_x` and `public_y`
* public methods will be: `foo`, `bar`, `baz`


source:

* <https://stackoverflow.com/questions/15643172/make-delegated-methods-private>



### After Rails 5.2


After [https://github.com/rails/rails/pull/31944](this PR) in Rails 5.2
you can do:


```ruby

class User < ActiveRecord::Base
  has_one :profile
  delegate :first_name, to: :profile
  delegate :date_of_birth, :religion, to: :profile, private: true

  def age
    Date.today.year - date_of_birth.year
  end
end

User.new.age        # => 2
User.new.first_name # => Tomas
User.new.date_of_birth # NoMethodError: private method `date_of_birth' called for #<User:0x00000008221340>
User.new.religion # NoMethodError: private method `religion' called for #<User:0x00000008221340>
```


### How NOT to do it

There is misconception amongs developers that you can
place delegate on new line after private:


```ruby
class Bar
   def car
      12
   end
end

class Foo
   # delegate after private
   private
   delegate :car, to: :bar

   def bar
     Bar.new
   end
end

Foo.new.car
#=> 12

Foo.new.public_methods - Object.new.public_methods 
#=> [:car]
```

**As you can see this does not work !!!**

Read more [here](https://github.com/rails/rails/pull/31944) why

