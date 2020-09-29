---
layout: til_post
title:  "Ruby array"
categories: til
disq_id: til-74
---

Here is some list of Ruby Array operations and examples.

I'm just pasting here some cool examples for lates Ruby I use. Pls check full list of Array features for your Ruby version

* [Ruby 2.7.0 Array](https://ruby-doc.org/core-2.7.0/Array.html)


## detect Same element in two Ruby arrays

> Ruby `&` method [docs](https://ruby-doc.org/core-2.7.0/Array.html#method-i-26)

```ruby
['a', 'b', 'c', 'd', 'e'] & ['a', 'c']
# => ["a", "c"]

['a', 'c']   &  ['a', 'b', 'c', 'd', 'e']
# => ["a", "c"]
```
>  `['a', 'b', 'c', 'd', 'e'].&(['a', 'c'])` will also work

Symbols and strings are not the same!

```ruby
['a', 'b', :c, :d, :e] & ['a', 'c', :e]
# => ["a", :e]

['a', 'c', :e] & ['a', 'b', :c, :d, :e]
# => ["a", :e]
```

## different element in two Ruby arrays

> Ruby `difference` method [docs](https://ruby-doc.org/core-2.7.0/Array.html#method-i-difference)


```ruby
['a', 'b', 'c', 'd', 'e'].difference ['a', 'c']
# => ["b", "d", "e"]


['a', 'c'].difference  ['a', 'b', 'c', 'd', 'e']
#  => []
```

string and symbols:

```ruby
['a', 'b', :c, :d, :e].difference ['a', 'c', :e]
# => ["b", :c, :d]


['a', 'c', :e].difference ['a', 'b', :c, :d, :e]
 => ["c"]
```

