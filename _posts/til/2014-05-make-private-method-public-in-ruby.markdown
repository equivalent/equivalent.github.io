---
layout: til_post
title:  "Make private method public in Subclass in Ruby"
categories: til
disq_id: til-2
redirect_from:
  - "/tils/2/"
  - "/tils/2-make-private-method-public-in-subclass-in-ruby/"
---


```ruby
class Foo

  private

  def my_method
    'it work !'
  end
end
```

```ruby
Foo.new.my_method
# => NoMethodError: private method `my_method' called for #<Foo:0x00000003ddb8e8>

Foo.send :public, :my_method
Foo.new.my_method
# => "it work !" 

```

```ruby
class Bar < Foo
  public :my_method
end
```

```ruby
Foo.new.my_method
# => NoMethodError: private method `my_method' called for #<Foo:0x00000003ddb8e8>

Bar.new.my_method
# => "it work !" 
```


source

* <http://ruby-doc.org/core-2.1.1/Module.html#method-i-private>
* <http://stackoverflow.com/questions/2171743/make-instance-methods-private-in-runtime>
