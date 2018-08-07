---
layout: til_post
title:  'Convert string "true" and string "false" to boolean with Rails'
categories: til
disq_id: til-51
---

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


### Why do you need to know about this ?

The thing is `"false"` String is not the same as `false` Boolean. String `"false"` is
actually truthy value:

```ruby
expect("false").to be_truthy  # this will pass
expect(false).to be_falsey    # this will pass
expect("false").to eq false   # this will fail !
```

This is highly dangerouse as:

```
# app/controllers/stupid_controller.rb
class StupidController < ApplicationController
  def create
    user = User.create(email: params[:email])
    if params[:make_him_admin]
      user.make_him_an_admin!
    end

    render json: { result: 'ok' }
  end
end
```

Therefore if you submit:

```json
{
  "email":"foo@bar.com",
  "make_him_admin": "false"
}
```

You will make him admin!

`params['make_him_admin'] == "false"` and
`"false" != false` but it's actually evaluated as a truthy value (non
`false` and non `nil` means truthy) therefore that if statement pass !!


If you are expecting String values `"false"` `"true"` (or maybe `"t"`,`"f"`, ...) from
outside input I highly recommend to convert them to boolean before you
pass them to your code or store in DB

You should also consider doing this when:

* before storing to JSON store (postgresql)
* before rendering the value in JSON API
* before you apply logic in your code
* or if you are accepting checkbox value from Rails form helper
* Etc...




### Discussion

* <https://www.reddit.com/r/ruby/comments/95casw/convert_string_true_to_boolean_true_with_rails/>
