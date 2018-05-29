---
layout: article_post
categories: article
title:  "Rails Bounded contexts - the simple way"
disq_id: 50
description:
  Rails Bounded contexts via Value object interfaces
  Article in progress
---

This article is not finished yet !!!

> This article is still in progress !!! Lot of developers asked me for a
> preview of this article that's why I'm releasing it unfinished.
>
> please check on later once it's officially relased

The premiss of this article is to organize your business related classes
to `app/bounded_context/...` while still keep your Rails related classes
with correlation with Rails best practices.

If you do this right you will end up with a folder structure like this:

```
app
  views
    baskets
      show.erb
  models
    product.rb
    basket.rb
  controllers
    baskets_controller.rb
  bounded_context
    discounts
      basket_value.rb
      basket_serializer.rb
      twenty_percent_discount.rb
      compare_competitors_prices_discount.rb
      evil_corp_pricing_gateway.rb
```

While keeping Rails models & controllers  first class citizens of
application not violiting any Rails best practices. Bounded context
classes will be invoked directly from within the related model:

```ruby
@basket.discount.overal_discount
@basket.discount.total_price_after_discount
@basket.discount.as_json
```



## Example


Imagine you have a complex business logic that needs to be split into 40
different classes/objects. Although there are many way how to maintain
the code imagine a solution in which we would wrap all the **non-rails**
objects to a folder located in
`app/bounded_context/name_business_logic/*`

So for example let say we have a complex way how we calculate discounts
in online store.

```erb
-# app/views/baskets/show.erb
<p>You would normally pay <%= @basket.discount.total_price_before_discount %> GBP</p>
<p>Our price is: <strong><%= @basket.discount.total_price_after_discount %> GBP</strong> !</p>
<p>You will save <%= @basket.discount.overal_discount %> GBP</p>

```

```ruby
# app/controllers/baskets_controller.rb
class BasketsController < ApplicationController
  def show
    @basket = current_user.basket
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @basket.discount.as_json }
    end
  end
end
```


```ruby
# app/model/basket.rb
class Basket < ActiveRecord::Base
  has_many :products

  def discount
    @discount ||= Discount::BasketValue.new(self)
  end
end
```

```ruby
#app/bounded_context/discounts/basket_value.rb
module Discounts
  class Basket
    attr_reader :basket

    def initialize(basket)
      @basket = basket
    end

    # if custummer is buying 2 or more of the same product, he will get 20% off on the 2nd, 3rd, ... product
    def overal_discount
      duplicate_products = []
      discount = 0.0
      @basket.products.each do |product|
        if duplicate_products.include?(product)
          # give 20 % discount
          discount = discount + (product.price / 100.00 * 20.00)
        else
          duplicate_products << product
        end
      end
      discount
    end

    def total_price_after_discount
      total_price_before_discount - overal_discount
    end

    def total_price_before_discount
      @basket.products.sum(:price)
    end

    def as_json
      Discounts::BasketSerializer.new(self).as_json
    end
  end
end
```

```ruby
#app/bounded_context/discounts/basket_serializer.rb
module Discounts
  class BasketSerializer
    attr_reader :discount_basket_value

    def initialize(discount_basket_value)
      @discount_basket_value = discount_basket_value
    end

    def as_json
     {
       discount: discount_basket_value.discount,
       price_before_discount: discount_basket_value.total_price_before_discount,
       price_after_discount:  discount_basket_value.total_price_after_discount
     }
    end
  end
end
```

Now this is simple straight forward Value Object example.
Controller is able to render Rails view directly with those value object
values and if JSON format is requested value object will delegate object
serialization to another class => `Discounts::BasketSerializer`

You don't have to pay too much attention on the business implementation
of this. It's a stupid example top of my head. Point is that the code is
much better organized around your business logic in one place while not
violating any Rails standards:

```
app
  views
    baskets
      show.erb
  models
    product.rb
    basket.rb
  controllers
    baskets_controller.rb
  bounded_context
    discounts
      basket_value.rb
      basket_serializer.rb
```



You can expand this solution to any type of object pattern.

Imagine
a Servise object that would pull competetors prices via Gateway class.
Ad if the price of our discount (20% off of next product) still cannot
compeat with competetor we will give them same prace as competetor:


```ruby
#app/bounded_context/discounts/basket_value.rb
module Discounts
  class Basket
    attr_reader :basket

    def initialize(basket)
      @basket = basket
    end

    def overal_discount
      possible_discounts = []
      possible_discounts << 0.0
      possible_discounts << TwentyPercentDiscount.new(@basket.producs).call
      possible_discounts << CompareCompetitorsPricesDiscount.new(@basket.producs).call
      possible_discounts.sort.reverse.first
    end

    def total_price_after_discount
      total_price_before_discount - overal_discount
    end

    def total_price_before_discount
      @basket.products.sum(:price)
    end

    def as_json
      Discounts::BasketSerializer.new(self).as_json
    end
  end
end
```

```ruby
#app/bounded_context/discounts/twenty_percent_discount.rb
module Discounts
  # if custummer is buying 2 or more of the same product, he will get 20% off on the 2nd, 3rd, ... product
  class TwentyPercentDiscount
     attr_reader :duplicate_products, :products
     attr_accessor :discount

     def inintialize(products)
       @duplicate_products = []
       @discount = 0.0
       @products = products
    end

    def call
      products.each do |product|
        if duplicate_products.include?(product)
          # give 20 % discount
          self.discount = discount + twenty_percent(product.price)
        else
          duplicate_product << product
        end
      end
      discount
    end

    private

    def twenty_percent(price)
      price / 100.00 * 20.00
    end
  end
end
```

```ruby
#app/bounded_context/discounts/compare_competitors_prices_discount.rb
module Discounts

  # we will add a differencte of our price vs competitor as a discount
  class CompareCompetitorsPricesDiscount
    attr_reader :products
    attr_accessor :discount

    def initialize(products)
      @products = products
      @discount = 0.0
    end

    def call
      products.each do |product|
        competetor_price = EvilCorpPricingGateway.price_of(product.international_product_id)
        if competetor_price > product.price
          self.discount = competetor_price - product.price
        end
      end
    end
  end
end
```

```ruby
#app/bounded_context/discounts/evil_corp_pricing_gateway.rb
module Discounts
  module EvilCorpPricingGateway
    def self.price_of(international_product_id)
      resp = HTTParty.get("https://evilcorp.com/product/#{international_product_id}.json")
      hash = JSON.parse(resp)
      hash['product']['price'].to_f
    end
  end
end
```

So this code will try to calculate the discount from our "buy one next
one is 20% off" discount business decission or it will try to match the
different what our competitor is offering as a discount. We will give
customer the discount depending which
discount is better for him.

As you can see our business logic has grown but our folder structure
keeps everything in place:

```
app
  views
    baskets
      show.erb
  models
    product.rb
    basket.rb
  controllers
    baskets_controller.rb
  bounded_context
    discounts
      basket_value.rb
      basket_serializer.rb
      twenty_percent_discount.rb
      compare_competitors_prices_discount.rb
      evil_corp_pricing_gateway.rb
```



