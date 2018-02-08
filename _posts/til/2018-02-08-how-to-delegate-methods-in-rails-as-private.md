---
layout: til_post
title:  "How to delegate methods in Rails as private"
categories: til
disq_id: til-40
---


in Rails:

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

* https://stackoverflow.com/questions/15643172/make-delegated-methods-private

