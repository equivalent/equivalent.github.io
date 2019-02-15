---
layout: article_post
categories: article
title:  "Duck Typing in Rails"
disq_id: 56
description:
  In programming there is a powerful concept called "duck typing" in
  which you copmose objects without the need to worry what kind of type
  they are. You just call public interfaces methods and you expect them
  to "quack" like a duck. It walks like a duck and it quacks like a duck, then it must be a duck.

---

> Article is still in progress, I'm planing to release it by end of the
> weak


In programming there is a powerful concept called "Duck Type"

>  Duck typing in computer programming is an application of the duck test—"If it walks like a duck and it quacks like a duck, then it must be a duck" [Wikipedia](https://en.wikipedia.org/wiki/Duck_typing)

So here is an example Ruby code:

```ruby
class A
  def aa
    'aa'
  end
end

class B
  def call(a)
    a.aa
  end
end

class C
  def aa
    'cc'
  end
end

class D
end

a = A.new
a.aa
# => 'aa'

c = C.new
c.aa
# => 'cc'

d = D.new
d.aa
# NoMethodError (undefined method `aa' for D:Class)


B.new.call(a) # => 'aa'
B.new.call(c) # => 'cc'
B.new.call(d) # NoMethodError (undefined method `aa' for D:Class)
```

When we initialize  class `B` with instance of class `A`
 (so called **object composition**) then
we would call  `B#call` method that would call `A#aa` method.
Therefore `B.new(A.new).call => 'aa'`


When we initialize class `B` with instance of the class `C` it
will not be a problem because instance object of class `C` responds to
method `#aa`. Therefore `B.new(C.new).call => 'aa'`

> quacks like a duck, then it must be a duck

![Don't get offended it's just a rubber duck](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/duck-type.jpg)

When we initialize class `B` with instance of the class `D` which
instance object has no  method `aa` then we would get Exception error
that the method `D#aa` is not defined
Therefore: `B.new(D.new).call => NoMethodError (undefined method aa for D:Class)`


> Doesn't quack like a duck, then it's not a freaking duck

Therefore we don't have to do any check like:

```ruby
# You Don't need to do this
class B
  def call(a)
    raise "not a duck" if a.instance_of?(A)
    raise "not a duck" if a.instance_of?(B)
    a.aa
  end
end
```

### Rails have Ducks

Imagine you have this piece of code:

```ruby
class Duck < ActiveRecord::Base
  has_many :quacks
end

class Quack  < ActiveRecord::Base
  belongs_to :duck
end

module Paginate
  def self.paginate(scope, page: 1, limit: 10)
    scope.limit(limit).offsent(page * limit)
  end
end

def get_quacks(duck_ids)
  quacks = Quack.all
  quacks = duck_ids.any? ? quacks.where(duck_id: duck_ids) : []

  quacks = Paginate.paginate(quacks)
  quack
end
```

> I'm aware that `#get_quacks` method could be written differently, just for sake of argument
> lets leave the code as it is

Imagine you would want to find all the Quacks:

```ruby
duck1 = Duck.create!
duck2 = Duck.create!
duck3 = Duck.create!

Quack.create(duck: duck1)
Quack.create(duck: duck1)
Quack.create(duck: duck1)
Quack.create(duck: duck2)
Quack.create(duck: duck3)

get_quacks([duck1.id, duck2.id])
# => ActiveRecord::Relation [#Quack{}, ...]
```

But what if we are not passing any Duck ids ?

```
get_quacks([])
# => NoMethodError (undefined method `limit' for []:Array
```

one way would be to chock the type in the `Paginate#paginate` method:

```ruby
# don't do this !
module Paginate
  def self.paginate(scope, page: 1, limit: 10)
    return [] unless scope.instance?of(ActiveRecord::Relation) # don't do this !
    scope.limit(limit).offsent(page * limit)
  end
end
```

But this is just stupid.

Rails provides better way how to return empty representation of Active
Record Relation: `Quack.none`.  `none` method returns empty value
representation of ActiveRecord::Relation upon 
which you can call other relion scope methods:

```ruby

def get_quacks(duck_ids)
  quacks = Quack.all
  quacks = duck_ids.any? ? quacks.where(duck_id: duck_ids) : Quack.none

  quacks = Paginate.paginate(quacks)
  quack
end
```

> most ideal would be syntax `quacks = quacks.where(duck_id: duck_ids)`
> as if duck_ids is `[]`  in that case Rails adds ` AND 1=0 ` to the SQL
> call. Again I just wanted to show you one from of duck type in Rails

Point of this section is to show you there are many ways how to write
simmilar piece of logic. If you need to write an `if` statement chances
are the whole code can be re-wrote other way with a duck type. Sometimes
it's not worth it and `if` statement more readable code. But lot of times duck
typing will help you speed up the particular part of application.


### SOLID Ducks and Rails

...article still in progress
