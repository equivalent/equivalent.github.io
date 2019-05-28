---
layout: article_post
categories: article
title:  "Rails Bounded contexts - the simple way"
disq_id: 50
description:
  Rails Bounded contexts via interface objects
  Article in progress
---

This article is not finished yet !!!

> This article is still in progress !!! Lot of developers asked me for a
> preview of this article that's why I'm releasing it unfinished.
>
> please check on later once it's officially relased


In this Article I'll show you how I'm organizing business related
classes in [Ruby on Rails](https://rubyonrails.org/) so I benefit
from [Bounded Contexts](https://martinfowler.com/bliki/BoundedContext.html)
while still keep Rails conventions and best practices.

We (me and my collegues) are writing BE code following way for over a year
(dating since late 2017) to write BE API in Rails but I also use this pattern for
my personal projects in which the server renders HTML ([majestic monolith](https://m.signalvnoise.com/the-majestic-monolith/))


These applications are quite extensive in business logic. Therefore
considere the following pattern only when building long running large
applications where long term maintainability is the key.
Fololwing pattern may not be the best if you are building weekend project.

## Theory

The point of [Bounded Contexts](https://martinfowler.com/bliki/BoundedContext.html) is to organize the the code 
according of business boundaries.

That means you may have education application in which you have students teachers and their works in lessons. So two natural bounded contexts may be:

* `classroom` -> preparation of lesson on teacher's side, like adding slideshow, or uploading eductation documents for students
* `public_board` -> once the lesson is done, students can interact with each other works like comments, annotations, and receive notifications around those

As you can imagine both bounded context are interacting with same
"models" (Student, Teacher, Work, Lesson) just around different
business perspective.

That means you would place all related code for `classroom` to one folder and all related code to `public_board` to that folder

You can think about this folders  as Microservices where every responsibility lives in it's own application

> Now If you want to understand what I mean by "Microservices" following the "bounded contexts" please watch my talk
> [Web Architecture choices & Ruby](https://skillsmatter.com/skillscasts/11594-lrug-march)([mirror](https://www.youtube.com/watch?v=xhEyUYTuSQw)) or
> [Microservices • Martin Fowler](https://www.youtube.com/watch?v=wgdBVIX9ifA)

So what you are ultimately trying to achive is organize code into layers


![bounded contexts example 1](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/bounded-context-1.jpg)

Other good references explaining Bounded context

* [Elixir Phoenix 1.3 by Chris McCord - bounded context in Phoenix](https://youtu.be/tMO28ar0lW8?t=15m31s)



> You may be ask "So are Bounded Contexts something like namespaces e.g.: `/admin` and `/` ?"
> No, no their not. Think about this way every Bounded Context have
> its own code for admin e.g. `classroom/admin`
> `public_board/admin`. If you still don't understand it pls watch
>  [my talk](https://www.youtube.com/watch?v=xhEyUYTuSQw)


## Rails and Bounded Contexts

Now theory is beautiful, practice is  painful.

There are several good resources on Bounded Contexts in Ruby on Rails. Some
are calling for [splitting Rails into Bounded Context via Rails
Engine](https://medium.com/@dan_manges/the-modular-monolith-rails-architecture-fb1023826fc4)

> basically you create own Rails Engine `classroom` and another
> engine `public_board`. That means controllers and models are in
> their own Rails engine

Some are calling for [event architecture](https://www.youtube.com/watch?v=STKCRSUsyP0) to achive
Bounded context like in [Domain Driven Design in Rails book](https://blog.arkency.com/domain-driven-rails/)

> book is about creating isolated bounded contexts and then interacting in-between
> those bounded contexts via publishing events. Check out their [gem](https://railseventstore.org/) for more info.

Although I really like and respect all these suggestions they all are
trying to introduce something that Rails was not designed for. In my
opinion they are
trying to introduce new way of thinking so much that junior developers
cannot catch up with them. 

> Biggest benefit of Rails is that it is trying to be as friendly as
> possible to junior and senior developers by following certain conventions. And although those
> conventions may be annoying/limiting for large applications they form
> basis of community and framework that is still dominating in Ruby world
> for more then 15 years.


## Summary of this solution

Solution that I'll demonstrate here is not advising for "full" split into
bounded context But rather **pragmatic** partial bounded context in which we will
keep `views`, `models`,`controllers`, as they are in `app/views`
`app/controllers`, `app/models`.

We will move only the `app/jobs/*`, `app/mailers/*`, (and other business logic like  `app/services/*`)
into bounded contexts. Therefore we will end up with something like:

```
app
  models
  controllers
  views
  bounded_contexts
    classroom
      notify_students_job.rb
      notify_students_about_new_lesson_job.job
      student_mailer.rb
      teacher_mailer.rb
      lesson_deliver_service.rb
    public_board
      comment_posted_job.rb
      student_mailer.rb
```

But we will go even further. We will introduce **interface objects**
that will allow us to call related bounded contexts from perspective of
the Rails models.

For example:

```ruby
student = Student.find(123)
student = Student.find(654)

lesson = teacher.classroom.create_lesson(students: [student1, student2])

some_file = File.open('/tmp/some_file.doc') # or this could be passed from controller as params[:file]
lesson.classroom.upload_work(student: student1, file: some_file)

lesson.classroom.deliver_lesson

work = Work.find(468)
work.work_interaction.post_comment(student: student2, title: "Great work mate!")
```

## Example

Let say we have an application in which `Student` can create `Work`
inside a `Lesson`. On every `Work` other students can place a `Comment`.


In traditional Ruby on Rails application you organize code in this way:

```
app
  controllers
    students_controller.rb
    works_controller.rb
    lessons_controller.rb
    comments_controller.rb
  model
    teacher.rb
    work.rb
    lesson.rb
    student.rb
    comment.rb
  jobs
    process_works_job

lib
  some_custom_lib_for_correcting_student_age.rb
  some_custom_lib_for_for_correcting_comment_.rb
```

Let say the busines logic is following:

* teacher can create losson and add students to the lesson
* every student can create work inside that lesson
* once the teacher "delivers" the lesson then other students can place commennts on that work

Now if this would be a traditional Rails app we would just jam the
various business logic methods into related models and controllers:

```ruby

class Lesson < ActiveReccord::Base
  # ...
  deliver
    self.delivered = true
    self.save
    Teacher.all do |teacher|
      Mailer
    end
  end
  # ..
end

class Work < ActiveReccord::Base
  belongs_to :lesson
  # ...

  def process_works
    ProcessWorkJob.perform_later(work_id: self.id)
  end

  def can_be_commented?
    self.lesson.delivered?
  end
  # ...
end

# ...and so on
```

Now you cauld jam the busines related update/create methods to be in `app/service` folder (so called Service Objects) and
authentication methods to `app/policy` (e.g. [Policy Objects](https://blog.eq8.eu/article/policy-object.html), [Pundit Gem](https://github.com/varvet/pundit)

But still you will organize  along the "type of classes" not really do
any organization around "business logic"


```
app
  controllers
    students_controller.rb
    works_controller.rb
    lessons_controller.rb
    comments_controller.rb
  model
    teacher.rb
    work.rb
    lesson.rb
    student.rb
    comment.rb
  jobs
    process_works_job

lib
  some_custom_lib_for_correcting_student_age.rb
  some_custom_lib_for_for_correcting_comment_.rb
```



Now theory of bounded


If you do this right you will end up with a folder structure like this:


Theory of bounded context is to organize your code according to busines
logic. 

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



## Conclusion

Let me epmasize one more thing: This article took more over a year to be finilized. Behind it are
countless hours of learning, comparing and trying solutions. Lot of real development trial
and error so you have final form that I'm 100% confident with.


