---
layout: article_post
categories: article
title:  "Rails bounded contexts via value objects"
disq_id: 49
description:
  Bounded contexts and value objects
---


In this article I will present really simple way how to introduce
Bounded Contexts in Ruby on Rails application while still keep
Rails conventions and its simplicity and playfulness.

This solution will not be perfect. It will not solve all problems of
Bounded Contexts (like Microservices do). You will still be working with
monolithic Ruby on Rails application on a one database sharing the same
gems between boundaries.

But this is good !

This solution is trying to embrace monolith, Rails and simple technical
implementation. With this solution  both senior and junior developers can work with
it.

> This is a really really long article but it has really really
> interesting point. So please read it whole before judging.

### What are Bounded Contexts ?


Bounded contexts are isolateted scopes of code domain logic.

>  [Bounded Context by Martin Fowler](https://martinfowler.com/bliki/BoundedContext.html)

It means that you will group your code around the Domain its trying to
solve. In our case we will place the folder bounderies



### Example Application

Let say our example application is an Online Store where we have these
responsibilities:

* Product Listing (display product details, create / edit products)
* Basket
* Orders 
* Payment gateway (call 3rd party API that will make handle the payment for us)

For sake of simplicity we will not introduce any gems we will use vanilla
Rails (except for consideration of 3rd party SDK that will handle
payment) Also we will use same relational DB that ActiveRecord::Base can work
with (e.g. PostgreSQL)

Lets start simple. Let say we have these models:

```ruby
# app/models/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders
end

# app/models/order.rb
class Order < ActiveRecord::Base
  has_and_belongs_to_many :products
end

class Basket < ActiveRecord::Base
  belongs_to :user
  has_many :products
end
```


### What are Value objects ?

Let say we want to avoid problems with float numbers so we will store the
`price` of  the `products` as a column type `Integer`. We will store the
price `x  * 100`  and convert the price on the fly within our
application.

For example if product cost is EUR `4.25` we will store in db `425`.
I the product price is `123.00` we will store `12300`

> Please don't focus too much on why we would want to do this.
> Important part is the implementation of code
> solution.

One solution would be to do:

```ruby
# app/model/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders

  def price=(x)
    super((x * 100).to_i)
  end

  def price
    super(x/100.00)
  end
end

product = Product.new
product.price = 123.03
product.save
# collumn product now stores `12303`

product = Product.last
product.price
# 123.03
```

> `super` in Ruby will call the implementation method from within next
> step of ancestory chain. That means in our case it will call the
> original implementation of `ActiveRecord::Base` of those methods.


Imagine our Product model also needs to handle multiple currencies.
Business requirement is to only store the value in EURos in the DB.
and we would recalculate prices for different currencies (USD, GBP) with
current day exchange rate.


Let's continue with our code:


```ruby
# app/model/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders

  def price=(x)
    super((x * 100).to_i)
  end

  def price
    super(x/100.00)
  end

  def price_in(currency)
    case currency
    when 'EUR'
      price
    when 'GBP'
      convert_with_rate(PoundExchangeRate.call)
    when 'USD'
      convert_with_rate(DolarExchangeRate.call)
    end
  end

  private

  def convert_with_rate(rate)
    (price * DolarExchangeRate.call * 100).to_i / 100.00
  end
end

# lib/pound_exchange_rate.rb
module PoundExchangeRate
  def self.call
    Rails.cache.fetch 'PoundExchangeRate', expires_in: 12.hours do
      # some code to pull current dayly exchange rate from a bank API. Result example.: 0.89
    end
  end
end

# lib/dolar_exchange_rate.rb
module DolarExchangeRate
  def self.call
    Rails.cache.fetch 'DolarExchangeRate', expires_in: 12.hours do
      # some code to pull current dayly exchange rate from a bank API.Result example.: 1.12
    end
  end
end

product = Product.new
product.price = 123.03

product.price
# => 123.03
product.price_in('EUR')
# => 123.03
product.price_in('USD')
# => 137.79
price_in('GBP')
# => 109.49
```

The `DolarExchangeRate` and `PoundExchangeRate` will pull current
exchange rate from a Bank for that Currency vs EURo.
Then this code will cache the value for 12 hours so we don't have to
make that external HTTP call every time.

This particular implementation of the exchange service objects is not important.
What is important is that we implemented quite lot of logic directly in
our model.

We could introduce several different code designs to tackle this problem
so that the model is cleaner but in this case we will use Value Object:

```ruby
# app/model/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders

  def price=(x)
    super((x * 100).to_i)
  end

  def price_value
    @price_value ||= PriceValue.new(self)
  end
end

# lib/price_value.rb
class PriceValue
  attr_accessor :product
  delegate :price, to: :product

  def initialize(product)
    @product = product
  end

  def eur
    price
  end

  def usd
    convert_with_rate(PoundExchangeRate.call)
  end

  def usd
    convert_with_rate(DolarExchangeRate.call)
  end

  private

  def convert_with_rate(rate)
    (price * DolarExchangeRate.call * 100).to_i / 100.00
  end
end

product = Product.new
product.price = 123.03

product.price
# => 123.03
product.price_value.eur
# => 123.03
product.price_value.usd
# => 137.79
product.price_value.gbp
# => 109.49
```

> `delegate` method is standard Rails method for forwarding messages to
> different object. In our case it's like writing `def price; product.price; end`.

Or we can delegate the methods directly on from the model level to value
object:

```
# app/model/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders
  delegate :eur, :usd, :gbp, to: :price_value

  def price=(x)
    super((x * 100).to_i)
  end

  private

  def price_value
    @price_value ||= PriceValue.new(self)
  end
end


product = Product.new
product.price = 123.03

product.price
# => 123.03
product.eur
# => 123.03
product.usd
# => 137.79
product.gbp
# => 109.49
```

Much cleaner isn't it ?  Look at our model how tiny it is !


So if you google `Value Object` you will probably find simillar
examples. Value Object (by standard definition) are transformation
objects of a model on Read only level. You don't expect them to modify
anything just to transform existing values (so we don't write anything
to DB just convert them)

Well yeah but it's kindof shame that the `#price=` methods is sitting on
it's own in the model. When you think about it now we have 2 files that
are aware of the fact that you need to devide/multiple by `100` in order
to calculate the real price. It feels like it should implemeted by one
rule. 

We could just introduce a constant to our model e.g.:

```
# app/models/products.rb
class Product < ActiveRecord::Base
  # ...
  PRICE_DEVIDER = 100
  # ...

  def price=(x)
    super((x * PRICE_DEVIDER).to_i)
  end
end


# lib/price_value.rb
class PriceValue
  # ...

  def convert_with_rate(rate)
    (price * DolarExchangeRate.call * Product::PRICE_DEVIDER).to_i / Product::PRICE_DEVIDER.to_f
  end
end
```

...but there is still logic behind the fact you need to multiply. So
we've extracted the value, but logic is still all around the place.

Let's try this:

```ruby
# app/model/product.rb
class Product < ActiveRecord::Base
  has_and_belongs_to_many :orders

  def price=(x)
    super(PriceValue.prepare_value_for_db_store(x))
  end

  def price_value
    @price_value ||= PriceValue.new(self)
  end
end

# lib/price_value.rb
class PriceValue
  def self.prepare_value_for_db_store(raw_value)
    (raw_value * 100).to_i
  end
  # ...
end
```

Now only one file contains all the logic around the magic number 100.
Important thing to remember here is that the Value Objects serves as
helpers for the model. They main purpus is to serve the model so it's

## Introducing more complexicity 


## Other Solutions

Not sold on the idea of value objects as drivers of Bounded Contexts ?
Fair enough here are some other options:

### Microservices

Microservices are the most ideal implementation of Bounded Contexts.
They are micro applications build just for that one domain
responsibility that they need to solve. They are developed, deployed and
scaled independently running on isolated processes (e.g. own Docker containers or own VMs)
connected to own databases. Microservices are communicating
with each other via HTTP API (e.g.: JSON) together forming the product.

So for online store you would have one application
for product listing, one for orders, one for payment gateway, etc...

So yeah it's quite complicated solution. Cost of change is high.


### Rails engines of Bounded contexts

Few months ago really well written article entitled 
[Modular monolith with Rails engines](https://medium.com/@dan_manges/the-modular-monolith-rails-architecture-fb1023826fc4)
was published covering how to achieve Bounded Contexts in Ruby on Rails
thanks to generating mountable Rails engine for every domain scope.

So imagine if you had an online store you could generate:

```bash
rails plugin new product_listing --mountable
rails plugin new basket --mountable
rails plugin new orders --mountable
rails plugin new payments --mountable
```

> + you would introduce internal gems to contain shared code (e.g. 3rd
>   party communication, gateways, ...).

This way you would have models, controllers, views for that given domain
isolated therefore you would introduce Bounded Contexts and team can be better guided
to introduce more clarity in for the domains.

Now I fully agree with this approach however in some cases this may be
quite a mission to maintain. It's still much easier than microservices
but quite time consuming (and we love Rails because it's simple)

Another problem is that this solution invoke false feeling of isolation
without consequences for Junior developers. Yes the domain code is isolated but
 bounded contexts are sharing same relational database
(e.g. PostgreSQL) or dependencies (gems and 3rd party lib).

If one team in one bounded
context changes the table other will be affected too. If one team
updates a gem dependancy it may fail for other bounded context.

> There are theoretical ways how every model could have its own Active Record DB connection, or
> every mounded engine could have just non Active Record solutions to
> persist data e.g. use AWS Dynamo DB via [aws-sdk](@todo). If you know
> what are you doing then this is not a limitation
>
> But I will not talk about those aproaches in this article as I want to show you
> how to achieve Bounded Contexts and still not violate the Rails philosophies around ActiveRecord

> Problem with gem dependency sharing between different Bonuded Contexts
> may or may not be problem depending on how much you rely on them or
> how your team communicates. If your team would had a discussion every
> time there would be a gem added / changed or if the entire development
> team decides to just stick with vanilla Rails (+just handful amount of
> gems) then you should be fine.

This may not be a problem for more experienced teams that can keep watch
on not introducing conflicts on DB or Gem level. It feels like
if junior/mid level jumps to the Rails engines bounded contexts solution they may fail pretty quickly.

So again in my opinion it's a great solution but you need to know what
you are doing.





