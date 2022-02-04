---
layout: til_post
title:  "How to test performance of caching with RSpec in Rails"
categories: til
disq_id: til-94
---

e.g.: if you implemeted fragment caching or russian doll caching

```
account = Account.last
Rails.cache.fetch ['posts', account] do
  # ....
end
```

### how to enable cache in single test

NOTE by default caching is disabled in test enviroment (which is a good
thing). You **don't** need to change default `null_store` caching

```ruby
# config/environments/test.rb
Rails.application.configure do
  # ...
  config.cache_store = :null_store #  feel free to keep this as it is
```

What we want is enable the caching only for particular test:


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


> Credit for this part of article goes to Emanuel De and his article [How to: Rails cache for individual rspec tests](https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests) Consider this as a mirror article

### RSpec tag to mark which tests should enable cache

we can go step further and enable cache only on tests with specific  RSpec tag / filters


```ruby
# spec/support/test_file_caching_helper.rb
module TestFileCachingHelper
  def self.cache
    return @file_cache if @file_cache
    path = "tmp/test#{ENV['TEST_ENV_NUMBER']}/cache"
    FileUtils::mkdir_p(path)
    @file_cache = ActiveSupport::Cache.lookup_store(:file_store, path)
    @file_cache
  end
end
```

```ruby
# spec/rails_helper.rb

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # ...

  # tests that use Rails cache https://blog.eq8.eu/til/how-to-test-caching-on-individual-tests-rails-rspec.html
  config.before(:example, :cache_enabled) do
    Rails.cache.clear
    allow(Rails).to receive(:cache).and_return(TestFileCachingHelper.cache)
  end
  # ...
end

```


```ruby
# spec/any_spec.rb
require 'rails_helper'
RSpec.describe 'Anything' do
  it 'should behave like test without cache enabled'
    # ...
  end

  it 'should behave like test with enabled cache', :cache_enabled
    # ...
  end

  context 'entire section under influence of cache', :cache_enabled do
    it 'should behave like test with cache enabled' do
      # ...
    end

    it do
      Rails.cache.fetch 'hello' { 123 }
      expect(Rails.cache.fetch('hello').to eq 123
    end
  end
end
```





### how to test performance of implemented caching

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

  it 'is performant', :cache_enabled do
    #First call
    expect { trigger }.to make_database_queries(count: 420..430)

    # cache kicked in
    expect { trigger }.to make_database_queries(count: 7)
  end
```

> note don't use let(:trigger) { get :index } as that will memoize the
> call => second call will not trigger

### sources

* <https://guides.rubyonrails.org/caching_with_rails.html>
* <https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests>

### Discusion
