---
layout: til_post
title:  "Issue with removing/deleting element from Ruby Array"
categories: til
disq_id: til-74
---




There is a famous dangerous Ruby Array issue when removing/deleting
element from Array


```ruby
a = [1, 2, 3 ]
b  = a

b.delete(2)

b
#=> [1, 3]

a
#=> [1, 3]
```

Similar problem:



```ruby
c = [1, 2, 3 ]
d  = c

d << 4

d
#=> [1, 2, 3, 4]

c
#=> [1, 2, 3, 4
```

## WTF? Why ?!

There is a good reason why this exist and that reason is **Performance**.

![](https://meme.eq8.eu/feature.jpg)


> I'll try to explain this best to my knowledge but as I've lerned about this like 10 years ago. So my explanation may not be 100% accurate.

Ruby is not the fastest language so in some places core developers used
pragmatic solution to gain performance.

If I remmember correctly Ruby delegates Array calculations to underlying `C` lang lib. This is so that
Array logic will be faster compared to if it was written in pure Ruby.

> Same approach take several gems. Take gem [MiniMagic](https://github.com/minimagick/minimagick) for image manipulation. It's using [ImageMagic](https://imagemagick.org/index.php) C lib for heavy lifting.


So think  about it this way.  When Ruby creates new array (`Array.new` or `[]`) it's really
just a pointer to C lang representation of the Array with all it's caviats.

```ruby
a = []
```

```
a  --------->   C Array logic.
```

Therefore `a` is just pointer to object in computer memmory not really Array

When you do

```ruby
a = b
```

You really set in `b` the same pointer as `a` is pointing to


```
a  ------\
          >----> C Array logic.
b  ------/
```


## How to get around this

here are few options how to get around this problem:


#### Clone the array

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

#### Freeze your array

In order to prevent your Junior developres to do this mistake you may
want to freeze the array

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
