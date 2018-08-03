---
layout: article_post
categories: article
title:  "Back to the primitive. Testing with simplicity"
disq_id: 52
description:
  Our tests (same as our code) needs to be maintained and clean.
  Therefore we often try to reuse parts of application in the tests.
  This may lead to several problems that we may get away with if we just
  tested the most primitive objects we can like "Strings, Integers" etc.

---

In Ruby on Rails imagine that your controller is generating this JSON
API:

```ruby
# app/controller/users_controller.rb
class UsersController < ApplicationController
  def show
     @user = User.find(params[:id])

     render json: {
       name: @user.name,
       href: user_path(@user)
     }
  end
end
```

This would generate JSON:

`curl GET localhost:3000/users/123`

```json
{
  "name": "Tomas",
  "href": "/users/123"
}
```

> Code samples are related to Rails 5.2 and RSpec 3.7

How would we test this ? Recently I've stumble upon a test that looks
like this:


```ruby
# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController do
  describe 'GET show' do
    let(:user) { User.create name: 'Tomas' }

    def trigger
      get :show, params: { id: user.id }
    end

    it 'expects JSON with profile link' do
      expect(response.status).to eq 200

      expect(JSON.parse(body)).to match({
        name: user.name,
        href: user_path(user)
      })
    end
  end
end
```

> This style of JSON API testing is explained better in
> article [Pure RSpec JSON API testing](https://blog.eq8.eu/article/rspec-json-api-testing.html)

So what is wrong with this test? Technically speaking nothing, However the Devil is in the detail.

You see  the Controller code is using `user_path(user)` and test is also
using `user_path(user)`:


```ruby
# app/controller/users_controller.rb
# ...
render json: {
  # ...
  href: user_path(@user)
}
# ...

# spec/controllers/users_controller_spec.rb
# ...
expect(JSON.parse(body)).to match({
  # ...
  href: user_path(user)
})
# ...
end
```

That is not necessary a problem, there is no harm in using helper methods in
test **if they are tested** !

Reason why we even have the `user_path` helper method is that we are doing
this in our routes:

```ruby
# config/routes.rb
# ...
resources :users, only: [:show]
```

...and thanks to  Rails magic this will among other things define a
helper method `user_path()`.

Therefore if someone overrides the helper method:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def user_path(*)
    "ha ha ha, your tests are Flaky !"
  end
end
```

... the test will still pass but your JSON API now have a bug in
critical JSON field value.

We could write a test for `user_path` method:

```ruby
# spec/helpers/apprication_helper_spec.rb
RSpec.describe ApplicationHelper, type: :helper do
  describe '#user_path' do
    let(:user) { User.new id: 123 }

    it 'should generate path for user url' do
      expect(user_path(user)).to eq('/users/123')
    end
  end
end
```

...but in reality this is not a common practice in Rails world

Rails developers don't bother writing tests for Rails
generated methods because the implementation is already tested within
framework, so it's just given that they do their job properly.

And attempts to override methods this way should be prevented by code
review (like with [Github flow](https://guides.github.com/introduction/flow/) PR reviews)

So lets have a look on different style of testing.

### Testing with primitive values

Instead of writing helper tests, we could just test what we do expect
form the output with the most **primitive** (simple) value possible:

```ruby
# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController do
  describe 'GET show' do
    let(:user) { User.create name: 'Tomas' }

    def trigger
      get :show, params: { id: user.id }
    end

    it 'expects JSON with profile link' do
      expect(response.status).to eq 200

      expect(JSON.parse(body)).to match({
        name: 'Tomas',
        href: "/users/#{user.id}"
      })
    end
  end
end
```

This way you can guarantee the controller produces API values even if
bunch of methods get override.

We are truly expecting a "string value" not just result of a method.

> Yes there is always a level on what can be tested this way. I'm just
> saying when possible try to work with plain values in tests.

There are times you want to compare two objects `expect(my_obj).to be(my_obj)`.
But you really need to have a reason to describe the test this way not do it by default.

And yes it may lead to more "brittle tests" (tests that fail for minor changes) but at least those tests prove the result.

> In accounting profession the act of "bookkeeping" reflects upon checking
> the "debits" and "credits". Debits (on left side of spreadsheet) must equal Credits (on right side of spreadsheet).
> Imagine Debit is like your code, Credit is like your test that would prove that you
> didn't loose money.
>
> Now imagine your code is a $1 000 000 worth Debit. You will try your
> darn best to make sure that the test you write would be as accurate as
> possible.
>
> Would you just work with estimates: "We had sales around 1 000 000 and we needed to pay around 900 000 for material and 100 000 salaries, it should be fine")
>
> Or would you crunch real "simple" numbers: "1 001 923 credit, debit on
> 900 999 material, 101 983 on salaries, Oh shit! This doesn't add up!

Simplicity is good !

> I recommend talk [Rails Conf 2012 Keynote: Simplicity Matters by Rich Hickey](https://www.youtube.com/watch?v=rI8tNMsozo0)

### Random data and Faker

But what about with random data like with [Faker gem](https://github.com/stympy/faker) ?

In previous test we were testing:

```ruby
expect(JSON.parse(body)).to match({
  name: user.name,
  # ...
```

Now we are testing


```ruby
expect(JSON.parse(body)).to match({
  name: 'Tomas',
  # ...
```

If we would create the user object with `let(:user) { User.create name: Faker::Name.first_name }` we would end up
with random name each time therefore the 2nd version of the test would fail.

I fully respect testing with random data as that helps discovering of
errors normally developers have no chance to. The thing however is
that lot of developers miss the point that they should be testing random
data like object type + object value compare:

```ruby
# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController do
  describe 'GET show' do
    let(:user) { User.create name: Faker::Name.first_name }

    def trigger
      get :show, params: { id: user.id }
    end

    it 'expects JSON with profile link' do
      expect(response.status).to eq 200

      json_body = JSON.parse(body)
      expect(json_body).to match({
        name: be_kind_of(String),
        href: be_kind_of(String)
      })

      expect(json_body.fetch(:name)).to eq user.name

      expect(user).to be_kind_of(User) # if the `user` is nil you will get unexpected values
      expect(json_body.fetch(:href)).to eq user_path(user)
    end
  end
end
```

Does a sentence "This is just stupid" goes trough your mind?

No it's not stupid it's just different flavor of testing with more OOP
involved in the test code. You need to realize if you going to mix OOP principles into the
test code recipe you need to test the objects on several layers.

> Don't get me started on stubbing methods interfaces in controllers, that's an article
> for several pages

My point is YES you can write your tests as a  OOP code. But you need to
fully take responsibility in what parts of your test code may the
object values change as you are not the only one who is contributing to
the project code.

Or you can write more simple tests with more primitive values (strings,
integers) and skip a layer or two of tests.


### Ecosystem of Rails ?

Although I use and respect notion of object oriented decoupling,
mocking school of testing, re-usability of code (even within tests) unit
testing, SOLID principles, etc;  the
truth is lot of times if you don't fully understnad what you are doing it will leave your code like this:

![Unit tests pass, but application sinks](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/unit-test-titanic.png)

...especially with Rails.

There are historic and architectural reasons around Ruby on Rails (not
Ruby, just Rails !) where authors took "decouple OOP" shortcuts in favor of
productivity. This also apply to mindset of developers working with it.

And that's good !

> Some sources of this claim:
>
> * [RubyRouges podcast DHH on Rails development](https://player.fm/series/all-ruby-podcasts-by-devchattv/rr-342-rails-development-and-more-with-david-heinemeier-hansson)
> * [RailsConf 2014 - Keynote: Writing Software by David Heinemeier Hansson](https://www.youtube.com/watch?v=9LfmrkyP81M)
> * [DHH, M. Fawler, K. Beck; Is TDD dead?](https://www.youtube.com/watch?v=z9quxZsLcfo) + article [DHH TDD is dead](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html)

You are NOT dealing with perfect OOP framework where everything can be
mocked, stubbed, reused, ...

And that's good !

Rails is hyperproductive web development framework for producing
products, not a University experimentation utopian OOP framework.

Therefore it's ok to take shortcuts when writing tests that make sense and help you
maintain stable product. Really you should care about the product not
just parts of it.


