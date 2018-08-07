---
layout: til_post
title:  'Convert string "true" and string "false" to boolean with Rails'
categories: til
disq_id: til-51
---

Imagine you wast to convert string `"true"` into boolean type `true`
before storing to JSON store (postgresql) or before rendering the value in JSON API
or before you apply logic in your code or if you are accepting checkbox
vaule from Rails form helper


### Rails 5

```ruby
ActiveModel::Type::Boolean.new.cast('t')     # => true
ActiveModel::Type::Boolean.new.cast('true')  # => true
ActiveModel::Type::Boolean.new.cast(true)    # => true
ActiveModel::Type::Boolean.new.cast('1')     # => true
ActiveModel::Type::Boolean.new.cast('f')     # => false
ActiveModel::Type::Boolean.new.cast('0')     # => false
ActiveModel::Type::Boolean.new.cast('false') # => false
ActiveModel::Type::Boolean.new.cast(false)   # => false
ActiveModel::Type::Boolean.new.cast(nil)     # => nil
```

source:

* <https://stackoverflow.com/a/44322375/473040>

### Rails 4.2

```ruby
ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
```

source

* <https://github.com/equivalent/scrapbook2#checkbox-radio-input-value-to-boolean>

### Rails 4.1 and bellow


```ruby
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 'f'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean 't'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '0'  # => false
ActiveRecord::ConnectionAdapters::Column.value_to_boolean '1'  # => true
ActiveRecord::ConnectionAdapters::Column.value_to_boolean nil  # => false
```

source

* <https://github.com/equivalent/scrapbook2#checkbox-radio-input-value-to-boolean>
* <https://gist.github.com/equivalent/3825916>


### Discussion

* <https://www.reddit.com/r/ruby/comments/95casw/convert_string_true_to_boolean_true_with_rails/>
