---
layout: article_post
categories: article
title:  "Explicit contracts for Rails - HTTP API usecase"
disq_id: 99
description:
  HTTP Explicit contracts are  straight forward way how to write fixtures
  like tests for
  consuming 3rd party APIs. They can be easier to maintain compare to mocks
---


In this article we will have a look on how to write Explicit Contract
tests for Ruby on Rails application with [RSpec](http://rspec.info)
that consume external 3rd party HTTP JSON API.


> In October 2015 Platformatec released an article
> "[Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)" related
> to testing Phoenix (Elixir lang.) framework.
> I'm pretty much covering the same thing from perspective of Ruby on
> Rails framework. If you already read that article you will not find
> anything new here.

### Gateway objects and Gateway mocks

Imagine we need to consume 3rd party  API 
in order to import students to our system.
So we need to build a controller that will pull the students
and save them to our DB.

Let say this 3rd party API endpoint can be accessed with
`GET https://third-party-provider.org/v1/students` and the response
looks like this:

```json
{
  "students": [
    { "name": "Tomi", "age": "10" },
    { "name": "Zdenka", "age": "12" },
    { "name": "Majko", "age": "15" },
    # ... and more
  ]
}
```

Now what we can do is create an **Gateway object** that will be
responsible for fetching this data:

> For simplicity we will use [HTTParty gem](https://github.com/jnunemaker/httparty) for making HTTP requests


```ruby
# lib/third_party_gateway.rb
require 'httparty'

module ThirdPartyGateway
  extend self

  def fetch_students
    resp = HTTParty.get('https://third-party-provider.org/v1/students')
    JSON.parse(resp.body)
  end
end
```

So now our controller for pulling and saving Students could look like
this:

```ruby
class StudentsController < ApplicationController

  # ...

  def pull
    pulled_student_list = ThirdPartyGateway.fetch_students['students']

    pulled_student_list.each do |pulled_student|
      student = Student.new
      student.name = pulled_student['name']
      student.age = pulled_student['age']
      student.save!
    end
  end
end
```

> Of course this can be a Service Object or maybe a ActiveJob background
> job, or anything really. The point is just that our Gateway module is only
> responsible providing the data as a simple hash structure.


How would we test this ?

Well one idea would be to **mock** the Gateway class:

```ruby
# spec/controllers/students_controller

RSpec.describe StudentsController do
  describe 'POST /studnets/pull' do
    def trigger
      post :pull
    end

    let(:mock_data_from_3rd_party) do
      "students" => [
        { "name" => "Tomi", "age"=> "10" },
        { "name" => "Zdenka", "age" => "12" }
      ]
    end

    before do
      expect(ThirdPartyGateway)
        .to receive(:fetch_students)
        .and_return(mock_data_from_3rd_party)
    end

    it 'should pull and store the student information from 3rd party provider' do
      expect(trigger).to change { Student.count }.by(2)

      student = Student.first
      expect(student.name).to eq 'Tomi'
      expect(student.age).to eq 10
    end
  end
end
```

Now this may look like good enough solution for this simple example but
when it comes to more complicated scenarios it may get out of hand
pretty quickly.

What if you need  to pull the data  in multiple parts of your
application?
What if you are dealing with multiple other endpoints (e.g. GET
teachers, POST student works, ...)

Although it is possible to deal with this scenarios by shared mocks, they
quickly may get out of sync between different cases and suddenly your
tests may tell a lie.

You see mocking individual endpoint requests
are more like `Factories`. They are good for unit tests. But with 3rd
party APIs we really looking for a solution similar to
`Fixtures`. So one source of truth for all scenarios that may happen.

### Gateway contracts

Lets refactor our Gateway module a bit. We will introduce
`ThirdPartyGateway::HTTP` and `ThirdPartyGateway::Test` modules:


```ruby
# lib/third_party_gateway/http.rb
require 'httparty'

module ThirdPartyGateway
  module HTTP
    extend self

    def fetch_students
      resp = HTTParty.get('https://third-party-provider.org/v1/students')
      JSON.parse(resp.body)
    end
  end
end
```

```ruby
# lib/third_party_gateway/test.rb

module ThirdPartyGateway
  module Test
    extend self

    def fetch_students
      {
        "students": [
          { "name": "Tomi", "age": "10" },
          { "name": "Zdenka", "age": "12" }
        ]
      }
    end
  end
end
```

now we are able to call:

```ruby
ThirdPartyGateway::Test.fetch_students  # data in our hash/file (like fixture)
ThirdPartyGateway::HTTP.fetch_students  # real HTTP call
```

> NOTE ! If you are consuming multiple different 3rd party APIs, then
> every API should have own contract class/module (E.g. `PayPal::Test`/
> `PayPall::HTTP`, `Stripe::Test`/`Stripe::HTTP`, ...)

Lets configure our Production & Developmennt enviroment to use HTTP
Gataway and
our Test environment to use Test Gateway.

```ruby
# config/environments/development.rb

require 'lib/third_party_gateway/http.rb
Rails.application.configure do
  # ...
 config.x.third_party_contract = ThirdPartyGateway::HTTP
  # ...
end
```

```ruby
# config/environments/production.rb

require 'lib/third_party_gateway/http.rb
Rails.application.configure do
  # ...
 config.x.third_party_contract = ThirdPartyGateway::HTTP
  # ...
end
```

```ruby
# config/environments/test.rb

require 'lib/third_party_gateway/test.rb
Rails.application.configure do
  # ...
 config.x.third_party_contract = ThirdPartyGateway::Test
  # ...
end
```

> Prefixing the confix with `x` is a Rails standard way to define custom
> confix values in enviroment files (config.x.anything_i_like = true) 
> [Read more here](http://guides.rubyonrails.org/v4.2/configuring.html#custom-configuration)

Now our controller can look like this:

```ruby
class StudentsController < ApplicationController

  # ...

  def pull
    pulled_student_list = third_party_contract.fetch_students['students']

    pulled_student_list.each do |pulled_student|
      student = Student.new
      student.name = pulled_student['name']
      student.age = pulled_student['age']
      student.save!
    end
  end

  private

  def third_party_contract
    Rails.configuration.x.third_party_contract
  end
end
```


So our test may look like this now:

```ruby
# spec/controllers/students_controller

RSpec.describe StudentsController do
  describe 'POST /studnets/pull' do
    def trigger
      post :pull
    end

    it 'should pull and store the student information from 3rd party provider' do
      expect(trigger).to change { Student.count }.by(2)

      student = Student.first
      expect(student.name).to eq 'Tomi'
      expect(student.age).to eq 10
    end
  end
end
```


### Testing Test contracts themself

Now what about a situation when 3rd party changed their API ?

> This should never happen (In theory) but sometime you may be consuming
> API from 3rd parties that are less diligent and they do mistakes that
> may leave your pull script do harm to your product.

With test contracts you can write one "slow" integration test that will
ensure nothing has changed on the 3rd party API and ensure that your Test
contract is valid.

```ruby
# spec/lib/third_party_gateway

RSpec.describe "ensure the test contract don't tell a lie" do
  it do
    http_student = ThirdPartyGateway::HTTP.fetch_student.fetch('students').first
    test_student = ThirdPartyGateway::Test.fetch_student.fetch('students').first

    expect(http_student.keys).to match_array(test_student.keys)
  end
end
```


> To learn more about JSON API testing with native RSpec you can read my
> other article [Testing API with RSpec](https://blog.eq8.eu/article/rspec-json-api-testing.html)

This will ensure that that the keys of the `students` fields didn't
changed. It maybe a case where  required key was removed from 3rd party API that could
cause our internal system serious damage (e.g. if ID is missing we are
deleting rows in our DB)

It's a not bullet proof solution, but better than blind mocks / request recordings
(discussed in "Other Solutions section)


### Dealing with variants

Imagine your gateway needs to POST some data to 3rd party API resulting
in  successful response with body `{result: 'ok'}` or bad request with
body `{result: 'error', errors: ['invalid format']}`

With mocks this would be easy. We would just mock the request and return
result for every scenario needed.

```ruby
# app/controllers/students_controller.rb
class StudentsController < ApplicationController
  # ...

  def create
    resp = HTTParty.post('https://third-party-provider.org/v1/students', name: params[:name], age: params[:age].to_i)
    case JSON.parse(resp)['result']
    when 'ok'
      # ... do some further processing
    when 'error'
      # ... render some error to FE
    else
      raise 'unknown edgecase'
    end
  end
end
```

```ruby
# spec/controllers/students_controller
RSpec.describe StudentsController do

  # ...
  describe 'POST create' do
    def trigger
      post :create, age: age, name: "Rene"
    end

    context 'when proper age for a student' do
      let(:age) { 12 }

      before do
        expect(HTTParty)
          .to receive(:post)
          .with(name: "Rene", age: age)
          .and_return({result: 'ok'})
      end

      it do
        trigger
        # ..
      end
    end

    context 'when too old for a student' do
      let(:age) { 31 }

      before do
        expect(HTTParty)
          .to receive(:post)
          .with(name: "Rene", age: age)
          .and_return({result: 'error', errors: ['Student too old']})
      end

      it do
        trigger
        # ....
      end
    end
  end
end
```

**How would you write a test for this with test contracts ?**

Now remember, contract tests tests behave similar way how would DB
fixtures behave. That means that there are variants built within the
contract:


```ruby
# lib/third_party_gateway/http.rb
require 'httparty'

module ThirdPartyGateway
  module HTTP
    # ...

    def create_student(name:, age:)
      resp = HTTParty.post('https://third-party-provider.org/v1/students', name: name, age: age)
      JSON.parse(resp.body)
    end
  end
end
```

```ruby
# lib/third_party_gateway/test.rb

module ThirdPartyGateway
  module Test
    # ...

    def create_student(name:, age:)
      if age < 18
        {result: 'ok'}
      else
        {result: 'error', errors: ['Student too old']}
      end
    end
  end
end
```

```ruby
class StudentsController < ApplicationController
  # ...

  def create
    resp_hash = Rails.configuration.x.third_party_contract.create_student(name: params[:name], age: params[:age].to_i)
    case resp_hash['result']
    when 'ok'
      # ... do some further processing
    when 'error'
      # ... render some error to FE
    else
      raise 'unknown edgecase'
    end
  end
end
```

```ruby
# spec/controllers/students_controller
RSpec.describe StudentsController do

  # ...
  describe 'POST create' do
    def trigger
      post :create, age: age, name: "Rene"
    end

    context 'when proper age for a student' do
      let(:age) { 12 }

      it do
        trigger
        # ..
      end
    end

    context 'when too old for a student' do
      let(:age) { 31 }

      it do
        trigger
        # ....
      end
    end
  end
end
```

> Now this may not be the best example as probably you want to rather
> create scenarios around HTTP status codes. So on success 201 or bad
> request 400 you may raise exception from within contact and capture it
> in the code. Really this is not the important part and it's really up
> to you or your team/product definition what you need / like.


### Conclusion (on Contracts)

Contracts are much better representation of behavior of an external APIs.
They may be bit inconvinient when dealing with several different
scenarios but that's the whole point. Your application is consuming
3rd party application => you are suddenly introducing "something" to
your application that you have not full controll of. Mocks may be easier
for writing but also easier to introduce a lie. Contracts are
representation of this inflexible reality.

### Other Solutions

Now there are many ways in Ruby on Rails world how to write the same
test. You can:

* Mock/Stub the data (`expect(HTTParty).to receive('get').with('https://blog.eq8.eu/feed.xml').and_return(mock_data)`)
* [Webmock](https://github.com/bblimke/webmock) gem, that will allow you to write more HTTP mocks
* use [VCR gem](https://github.com/vcr/vcr) to record the real HTTP calls and next time the tests will just use
  data recorded during first run

These approaches are valid but in lot of cases they are hard to
maintain. Test contracts are my favorite approach  in 70% of situations
when it comes to dealing with 3rd party API.

### When Explicit Contracts are bad idea

One example of when it's a bad idea to use Explicit contract for tests
is when you are using 3rd party gem for HTTP call that is providing
DSL and functionality around returned data.

For example [Unsplash rb
gem](https://github.com/unsplash/unsplash_rb) will let you do
something like:


```ruby
photo = Unsplash::Photo.find('TcUY4zjKXL0')
photo.photo.urls.regular # url of a image
```

Gem is automatically wrapping returned JSON data with custom objects.
In this case I could create contract for the `.find` method where mock
contract would wrap the JSON data to `Unsplash::Photo.new(json_body)`
but problem is that I would "assume" how the gem will evolve in the
future.

```ruby
# example of when explicit cantract is a bad idea

module UnsplashContract
  module Http
    def find(id)
      Unsplash::Photo.find(id)
    end
  end

  module Mock
    def find(id)
      case id
      when 'TcUY4zjKXL0'
        json_body = '{"id": "TcUY4zjKXL0", "urls": [...], ...}'
        hash = JSON.parse(json_body) # too much knowledge about the gem
        Unsplash::Photo.new(hash) # too much knowledge about the gem , what if they change this ?
      else
        raise Unsplash::NotFoundError # too much knowledge about the gem, what if they change this ?
      end
    end
  end
end
```

It's fine to use contracts on 3rd party gems if they just serve as
Gateway objects returning plain data or simple Ruby hash. But if they have lot of functionality around data
you are far better of with [HTTP stubs](https://github.com/bblimke/webmock#stubbing-with-custom-response)

### sources

* <http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/>

* [Reddit Discussion](https://www.reddit.com/r/ruby/comments/8cj4no/explicit_contracts_for_rspec_rails/)
