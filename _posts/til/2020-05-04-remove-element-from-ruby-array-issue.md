---
layout: til_post
title:  "Issue with removing/deleting element from Ruby Array"
categories: til
disq_id: til-74
---


Imagine this situation:


```ruby
a = [1, 2, 3 ]
b  = a

b.delete(2)

b
#=> [1, 3]

a
#=> [1, 3]
```

Similar dangerous situation happens when you add elements to Array:


```ruby
c = [1, 2, 3 ]
d  = c

d << 4

d
#=> [1, 2, 3, 4]

c
#=> [1, 2, 3, 4
```

This is not really a issue. It's how Ruby works.

![](https://meme.eq8.eu/feature.jpg)

## Explanation


In Ruby lang  variables are assigned as a reference - they point to same
object ([source](https://www.ruby-lang.org/en/documentation/faq/4/#assignment))



```ruby
a = []
```

```
a  --------->  object
```

Therefore `a` is just reference to object in computer memory

When you do

```ruby
a = b
```

You really set in `b` the same reference as `a` is pointing to


```
a  ------\
          >----> object
b  ------/
```


### It's not just Array

This doesn't really have anything to do with Array, specifically. Ruby assigns by reference, so any method call that changes its receiver in-place has the potential to manifest this behavior.


Hash example:

```ruby
x = {id: 1, name: 'allisio', skill: 'pro' }
y = x
y.delete(:id)

y
# => {:name=>"allisio", :skill=>"pro"}

x
# => {:name=>"allisio", :skill=>"pro"}

y[:lang] = 'ruby'

y
# => {:name=>"allisio", :skill=>"pro", :lang=>"ruby"}

y
# => {:name=>"allisio", :skill=>"pro", :lang=>"ruby"}
```

String example:

```ruby
a = 'abcd'
b = a

b.gsub!('ab', 'xx')

b
# => 'xxcd'

a
# => 'xxcd'
```

Custom object example:

```ruby
class Foo
  attr_accessor :value
end

foo = Foo.new
foo.value = 1

bar = foo
bar.value =2

bar.value
# => 2

foo.value
# => 2
```


## Solution

Here are few options how to tell Ruby to reference a new object


#### Clone the object

```ruby
a = [1,2,3]
b = a.dup

b.delete(2)

b
# => [1, 3]

a
# => [1, 2, 3]
```

#### Do functional calculation

> There is famous statement in Functional programming world: "State is root of all evil"

You can performing functional operation  with the Array `a`  that results in returning new array:


```ruby
a = [1,2,3]
b = a - [2]

b
# => [1, 3]

a
# => [1, 2, 3]
```

Same for other objects

```ruby
a = 'abcd'
b = a.gsub('ab', 'xx')

a
# => 'abcd'

b
# => 'xxcd'
```

## Freeze your Object

In order to prevent your Junior developers to do this mistake you may
want to freeze the Array

```ruby
a = [1,2,3].freeze
b = a

b.delete(2)
# FrozenError (can't modify frozen Array)

b
# => [1,2,3]

a
# => [1,2,3]
```

## Special Thanks

In first version of the article I've described the problem from wrong
perspective

Thank you [allisio](https://www.reddit.com/user/allisio/) for the [help](https://www.reddit.com/r/ruby/comments/gdagcf/issue_with_removingdeleting_element_from_ruby/fpg7t8m?utm_source=share&utm_medium=web2x) on describing the problem correctly

## Related Articles


Here are some article that goes deeper into this topic:

* <https://launchschool.com/blog/object-passing-in-ruby>
* <https://launchschool.com/blog/references-and-mutability-in-ruby>

Similar topics:

* [Ruby Array](https://blog.eq8.eu/til/ruby-array.html)
* [Ruby Enumerable, Enumerator, Lazy and domain specific collection objects](https://blog.eq8.eu/article/ruby-enumerable-enumerator-lazy-and-domain-specific-collections.html))


## Discussion

* <https://www.reddit.com/r/ruby/comments/gdagcf/issue_with_removingdeleting_element_from_ruby/>
* <https://www.rubyflow.com/p/cnkxko-issue-with-removingdeleting-element-from-ruby-array>
