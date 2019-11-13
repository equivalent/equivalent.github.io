---
layout: til_post
title:  "RSpec mocks in Rails native tests (minitest)"
categories: til
disq_id: til-71
---

I love RSpec but recently I've decided to build sideproject with 100%
Rails 6 vanilla environment (that means no extra gems, just what is
inside Rails 6, including the Minitest test environment)

Problem is Minitest stubs and mocks suuuucks !

> If you are interested in Minitest mocks check [this article](https://semaphoreci.com/community/tutorials/mocking-in-ruby-with-minitest)

So I want to use Rails Minitest but RSpec mocks and this is how:

```ruby
# Gemfile

# ...

group :test do
  # ...
  gem 'rspec-mocks'
end

# ...
```


> note, no `rails-rspec` is not required

```ruby
# test/test_helper

# ...
require 'rspec/mocks/minitest_integration'
# ...

```


```ruby
require 'test_helper'

class AddPhoneControllerTest < ActionDispatch::IntegrationTest
  test 'POST create add phone to inzerat when valid arguments should redirect to enter code path' do
    post some_path, params: { phone: { country: 'sk', number: '908111222' } }

    expect(SmsGatewayContract.contract)
      .to receive(:send_sms)
      .and_call_original

    post_add_phone_to_inzerat
  end

end
```


more resources:

* <https://relishapp.com/rspec/rspec-mocks/docs/outside-rspec/integrate-with-minitest>

Alternatives:

* [minitest-mock_expectations](https://github.com/bogdanvlviv/minitest-mock_expectations)
