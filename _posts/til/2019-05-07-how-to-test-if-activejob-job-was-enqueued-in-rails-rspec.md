---
layout: til_post
title:  "How to test if ActiveJob job was enqueued in Rails RSpec"
categories: til
disq_id: til-60
---

> If you are looking for [How to tell RSpec to execute queued jobs](https://blog.eq8.eu/til/tell-activejob-to-perform_later-as-perform_now-in-test-or-spec.html) pls check [this note](https://blog.eq8.eu/til/tell-activejob-to-perform_later-as-perform_now-in-test-or-spec.html)


Given you are using [RSpec Rails gem](https://github.com/rspec/rspec-rails)

If you want to check if  code enqueued specific jobs you can do

```ruby

class SomeController < ApplicationController
  # ...

  def some_action
    # ...
    MyJob.perform_later(current_user_id: @current_user.id)
    # ...
  end
end


RSpec.describe SomeController do
  # ...

  let(:user) { User.create! }

  before do
    sign_in user
  end

  it 'should enqueue MyJob ' do
    post :some_action

    expect(MyJob)
      .to have_been_enqueued
      .with(current_user_id: user.id)
  end
```

Or:

```ruby
RSpec.describe SomeController do
  # ...

  let(:user) { User.create! }

  before do
    sign_in user
  end

  it 'should enqueue MyJob ' do
    expect{ post :some_action }
      .to have_enqueued_job(Notifications::PresentationNotificationSharedAleboAkoSaVola)
      .with(current_user_id: user.id)
  end
```

Let say you are creating multile items:


```ruby
class SomeController < ApplicationController

  def some_action
    products = [
      Product.create!(title: 'item 1'),
      Product.create!(title: 'item 2'),
      Product.create!(title: 'item 3')
    ]

    products.each do |product|
      MyJob.perform_later(current_user_id: @current_user.id, product_id: product.id)
    end
  end
end

RSpec.describe SomeController do
  # ...

  let(:user) { User.create! }

  before do
    sign_in user
  end

  it 'should enqueue MyJob for every created product' do
    expect { post :some_action }.to change { Product.count }.by(3)

    Product.last(3).each do |product|
      expect(MyJob)
        .to have_enqueued_job
        .with(current_user_id: user.id, product_id: product.id)
    end
  end
end
```

> note `.with(current_user_id: be_kind_of(Integer), product_id: be_kind_of(Integer))` will also work



### Source

* [relish rspec rails docs](https://relishapp.com/rspec/rspec-rails/docs/matchers/have-been-enqueued-matcher)

