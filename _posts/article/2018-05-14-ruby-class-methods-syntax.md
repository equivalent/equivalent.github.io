---
layout: article_post
categories: article
title:  "Ruby class methods syntax"
disq_id: 49
description:
  In Ruby there are several ways how to define a class method. In this
  article I'll go trough 4 major ways and explain what class methods
  really are.

---

In Ruby you are able to write class methods multiple ways.

We will quickly show  4 major ways and explain how they work and when you may want to use one
over the other:


### option 1  - def self.method_name

```ruby
class MyModel
  def self.what_is_your_quest
    "To find the Holly Grail"
  end

  def self.what_is_your_favorite_color(knight)
    case knight
    when "Lancelot"
      "blue"
    else
      "blue, ...no red !"
    end
  end

  def hello_world
    "this is an instance method"
  end
end

MyModel.what_is_your_quest
# => "To find the Holly Grail"

MyModel.what_is_your_favorite_color("Lancelot")
# => "blue"

MyModel.new.hello_world
# => "this is an instance method"
```

### option 2 - `class << self`


```ruby
class MyModel
  class << self
    def what_is_your_quest
      "To find the Holly Grail"
    end

    def what_is_your_favorite_color(knight)
      case knight
      when "Lancelot"
        correct_color
      else
        "#{correct_color}, ...no, red !"
      end
    end

    private

    def correct_color
      "blue"
    end
  end

  def hello_world
    "this is an instance method"
  end
end

MyModel.what_is_your_quest
# => "To find the Holly Grail"

MyModel.what_is_your_favorite_color("Lancelot")
# => "blue"

MyModel.correct_color
# => NoMethodError (private method `correct_color' called for MyModel:Class)

MyModel.new.hello_world
# => "this is an instance method"
```

### Option 3 - extend a module


```ruby
class MyModel
  module BridgeKeeperQuestions
    def what_is_your_quest
      "To find the Holly Grail"
    end

    def what_is_your_favorite_color(knight)
      case knight
      when "Lancelot"
        correct_color
      else
        "#{correct_color}, ...no, red !"
      end
    end

    private

    def correct_color
      "blue"
    end
  end
  extend BridgeKeeperQuestions

  def hello_world
    "this is an instance method"
  end
end

MyModel.what_is_your_quest
# => "To find the Holly Grail"

MyModel.what_is_your_favorite_color("Lancelot")
# => "blue"

MyModel.correct_color
# => NoMethodError (private method `correct_color' called for MyModel:Class)

MyModel.new.hello_world
# => "this is an instance method"
```

### Option 4 - instance eval

```ruby
class MyModel
  def hello_world
    "this is an instance method"
  end
end

MyModel.instance_eval do
  def what_is_your_quest
    "To find the Holly Grail"
  end

  def what_is_your_favorite_color(knight)
    case knight
    when "Lancelot"
      correct_color
    else
      "#{correct_color}, ...no, red !"
    end
  end

  private

  def correct_color
    "blue"
  end
end

MyModel.what_is_your_quest
# => "To find the Holly Grail"

MyModel.what_is_your_favorite_color("Lancelot")
# => "blue"

MyModel.correct_color
# => NoMethodError (private method `correct_color' called for MyModel:Class)

MyModel.new.hello_world
# => "this is an instance method"
```

> If you are experienced Ruby dude and you are like: "Wait a minute ! There are more than 4 ways !"
> then yes you are right but to be honest all those remaining ways are really
> doing one of these 4 things just different way.

## What class methods really are ?

When you look at *Option 4* you may be wondering: *Hmm, shouldn't that be `class_eval` ?* 

Answer is no ! `instance_eval` is correct

In Ruby everything is an object. Even class methods are
actually instance methods of the class object instance. Camel case
names like `MyModel` are nothing else then just constants referencing
these objects.

To prove that let me
reverse engineer the class instance backward:

```ruby
a = Class.new
#  => #<Class:0x0000000001a30b50> 

def a.what_is_your_quest
  "To find the Holly Grail"
end
# => :what_is_your_quest

MyModel = a

MyModel.what_is_your_quest
# => "To find the Holly Grail"

a.class_eval do
  def hello_world
    "this is an instance method"
  end
end

MyModel.new.hello_world
# => "this is an instance method"
```

> If it feels confusing run this example several times in `irb`

It's not a rocket science. When you do:

```ruby
class MyModel
end
```

...what you really create is a `Class.new` and assign it to constant
`MyModel` like: `MyModel = Class.new`


Then when you are defining "class methods":

```ruby
class MyModel
  def self.what_is_your_quest
    # ...
  end
end
```

...in reality you are defining
"instance methods" on this `Class` instance

This apply to every of the options I've mentioned above. Here is a
proof:


#### Option 1:

```ruby
my_model = Class.new do
  def self.what_is_your_quest
    "To find the Holly Grail"
  end

  def hello_world
    "this is an instance method"
  end
end

my_model.what_is_your_quest
# => "To find the Holly Grail"

my_model.new.hello_world
# => "this is an instance method"
```

#### Option 2:

```ruby
my_model = Class.new

class << my_model
  def what_is_your_quest
    "To find the Holly Grail"
  end
end

my_model.what_is_your_quest
# => "To find the Holly Grail"
```

> `self` is just the reference of current instance. So when we did
> `class << self` in the original Option 2 example we wrote exact
> equivalent of this example

#### Option 3:

```ruby
module BridgeKeeperQuestions
  def what_is_your_quest
    "To find the Holly Grail"
  end

  def what_is_your_favorite_color(knight)
    case knight
    when "Lancelot"
      correct_color
    else
      "#{correct_color}, ...no, red !"
    end
  end

  private

  def correct_color
    "blue"
  end
end

my_model = Class.new
my_model.extend(BridgeKeeperQuestions)
my_model.what_is_your_quest
# => "To find the Holly Grail"
```

#### Option 4

```ruby
my_model = Class.new
my_model.instance_eval do
  def what_is_your_quest
    "To find the Holly Grail"
  end
end
my_model.what_is_your_quest
# => "To find the Holly Grail"
```

## Which one to use ?

It really doesn't matter. Only argument is style of writing the class.

When you go with Option 1 you may end up with too many definitions in
the class:

```ruby
# app/model/my_model.rb
class MyModel
  def self.klass_method_1
  end

  def self.klass_method_2
  end

  def self.klass_method_3
  end

  def self.klass_method_4
  end

  def self.klass_method_5
  end

  # ...

  def initialize(foo)
    @foo = foo
  end

  def finally_my_instance_method
    @foo + "hi"
  end
end
```

...this way you may have too much knowledge in your code on the class (which we now
agreed is a different object) and not so much on the instance (which is
what the object oriented programming is trying to work upon)

> plus it's hard/confusing to do private class methods this way

When you go with Option 2:


```ruby
# app/model/my_model.rb
class MyModel
  class << self
    def klass_method_1
    end

    def klass_method_2
    end

    def klass_method_3
    end

    def klass_method_4
    end

    # ...

    private

    def private klass_method
    end

    # ...
  end

  def initialize(foo)
    @foo = foo
  end

  def finally_my_instance_method
    @foo + "hi"
  end
end
```

... you are able to do `private` methods easily but you will have the same problem as with Option 1:
"Too much knowledge around class". Plus it's super easy to lost context
on what are class methods and where instance methods start when you have long
enough file.

Option 4 is more an option for metaprogramming and when you are writing
libraries / overwriting libraries in your system.

So that leaves us with Option 3. When you are dealing with small amount
of class methods it's easy to maintain them within the same file:


```ruby
# app/model/my_model.rb
class MyModel
  module MyModelKlassMethods
    def klass_method_1
    end

    def klass_method_2
    end
  end
  extend MyModelKlassMethods

  def initialize(foo)
    @foo = foo
  end

  def finally_my_instance_method
    @foo + "hi"
  end
end
```

And once they get out of hand all you need to do is to extract them to
separate file:

```ruby
# app/model/my_model.rb
class MyModel
  extend MyModelKlassMethods

  def initialize(foo)
    @foo = foo
  end

  def finally_my_instance_method
    @foo + "hi"
  end
end

# app/model/concerns/my_model_klass_methods.rb
module MyModelKlassMethods
  def klass_method_1
  end

  def klass_method_2
  end

  def klass_method_3
  end

  def klass_method_4
  end

  # ...

  private

  def private klass_method
  end

  # ...
end
```

## How do I maintain my class methods

To be honest although Option 3 (extend module) is cool and all,
when I'm writing a code I keep my class methods defined
directly within the file with Option 1:

```ruby
# app/model/my_model.rb
class MyModel
  def self.klass_method_1
    # ...
  end

  def instance_method
    # ...
  end
end
```

And as soon as I see there is more than 3 class methods in the model
**that are related to same thing** I extract them to module. That means
I may end up with something like this:


```ruby
# app/model/my_model.rb
class MyModel
  extend MyModel::AccountingClassMethods
  extend MyModel::CartoonWatchingClassMethods

  def self.what_is_your_favorite_color
    # ...
  end

  def instance_method_1
    # ...
  end

  def instance_method_2
    # ...
  end
end

# app/model/my_model/accounting_class_methods.rb
module MyModel::AccountingClassMethods
  # ...
end

# app/model/my_model/cartoon_watching_class_methods.rb
module MyModel::CartoonWatchingClassMethods
  # ...
end
```

> In reality I'm using "Bound Contexts" to hold my related moduls/classes
> in place. So the file would be
> `app/bound_contexts/accounting/my_model_class_methods.rb` and `app/bound_contexts/cartoon_watching/my_model_class_methods.rb`
> but I'm preparing series of articles  on Bound Contexts where I'll
> explain that in details


The point is don't just blindly move class methods away from your
objects just so the models  are "clean". In reality you may actually create
bigger mess if you move unrelated class method level stuff of different
contexts.

That's why I don't like using `class << self` as it will scope all class methods as if they were
related.

In reality your class methods are representing different contexts that just behave similar way.

I hope you learned something new in this article. If not maybe you will
consider to prefer `extend` over `class << self`.

One more note: You can  maintain instance methods similar way too using `include` having a generic way
how to write code for instance and class methods.

### sources

* [The Ruby Object Model and Metaprogramming](https://pragprog.com/screencast/v-dtrubyom/the-ruby-object-model-and-metaprogramming)
* [Rails concerns](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
* [Reddit Discussion](https://www.reddit.com/r/ruby/comments/8jblfm/ruby_class_methods_syntax/)

