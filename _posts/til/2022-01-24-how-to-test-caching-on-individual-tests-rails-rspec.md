---
layout: til_post
title:  "How to test performance of caching on individual tests Rails RSpec"
categories: til
disq_id: til-94
---


### how to enable cache on single test

```ruby
# spec/any_spec.rb
module TestFileCachingHelper
  def self.cache
    return @file_cache if @file_cache
    path = "tmp/test#{ENV['TEST_ENV_NUMBER']}/cache"
    FileUtils::mkdir_p(path)
    @file_cache = ActiveSupport::Cache.lookup_store(:file_store, path)
    @file_cache
  end
end

before do
  allow(Rails).to receive(:cache).and_return(TestFileCachingHelper.cache)
  Rails.cache.clear
end

it do
  expect(Rails.cache.exist?('some_key')).to be(false)
  Rails.cache.write('some_key', 'test')
  expect(Rails.cache.exist?('some_key')).to be(true)
end
```


NOTE  you **don't** need to change default `null_store` caching

```ruby
# config/environments/test.rb
Rails.application.configure do
  # ...
  config.cache_store = :null_store #  feel free to keep this as it is
```


Credit goes to Emanuel De and his article
[How to: Rails cache for individual rspec tests](https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests) Consider this as a mirror note


### how to test performance

Gem  [db-query-matchers](https://github.com/civiccc/db-query-matchers)
will help you test how many SQL calls the request has made


```ruby
# Gemfile
# ...
group :test do
  gem 'rspec-rails'
  # ...
  gem 'db-query-matchers'
```

```ruby
# spec/controllers/accounts_controller_spec.rb
RSpec.describe AccountsController do
  # ...
  def trigger
    get :index
  end

  before do
    allow(Rails).to receive(:cache).and_return(TestFileCachingHelper.cache)
    Rails.cache.clear
  end

  it 'is performant' do
    #First call
    expect { trigger }.to make_database_queries(count: 420..430)

    # cache kicked in
    expect { trigger }.to make_database_queries(count: 7)
  end
```

### sources

* <https://guides.rubyonrails.org/caching_with_rails.html>
* <https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests>

### Discusion