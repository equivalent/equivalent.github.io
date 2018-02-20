---
layout: til_post
title:  "How to delegate methods in Rails as private"
categories: til
disq_id: til-40
---


### Rails before version 5.2


```ruby
class User < ActiveRecord::Base
  has_one :profile
  delegate :first_name, to: :profile

  def age
    Date.today.year - date_of_birth.year
  end

  private
  private *delegate(:date_of_birth, :religion, to: :profile)

  def other_security_info
    # ...
  end
end

User.new.age        # => 2
User.new.first_name # => Tomas
User.new.date_of_birth # NoMethodError: private method `date_of_birth' called for #<User:0x00000008221340>
User.new.religion # NoMethodError: private method `religion' called for #<User:0x00000008221340>
User.new.other_security_info # NoMethodError: private method `other_security_info' called for #<User:0x00000008221340>
```

source:

* <https://stackoverflow.com/questions/15643172/make-delegated-methods-private>



### After Rails 5.2


After [this PR](https://github.com/rails/rails/pull/31944) in Rails 5.2
you can do:


```ruby

class User < ActiveRecord::Base
  has_one :profile
  delegate :first_name, to: :profile
  delegate :date_of_birth, :religion, to: :profile, private: true

  def age
    Date.today.year - date_of_birth.year
  end

  private

  def other_security_info
    # ...
  end
end

User.new.age        # => 2
User.new.first_name # => Tomas
User.new.date_of_birth # NoMethodError: private method `date_of_birth' called for #<User:0x00000008221340>
User.new.religion # NoMethodError: private method `religion' called for #<User:0x00000008221340>
User.new.other_security_info # NoMethodError: private method `other_security_info' called for #<User:0x00000008221340>
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
   # plain delegate after private
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

To learn more read <https://github.com/rails/rails/pull/31944>

