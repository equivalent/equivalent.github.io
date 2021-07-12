---
layout: til_post
title:  "Rails Active Storage CDN"
categories: til
disq_id: til-90
---

Ruby on Rails  Active Storage  there is posibility to configure CDN.

### Set up Rails

```ruby
# config/environments/production.rb
Rails.application.configure do
  # ...
  config.x.cdn_host = 'https://myapp-stg.b-cdn.net'
  config.active_storage.resolve_model_to_route = :cdn_proxy
  # ...
```


```ruby
# config/environments/staging.rb
Rails.application.configure do
  # ...
  config.x.cdn_host = 'https://myapp-prod.b-cdn.net'
  config.active_storage.resolve_model_to_route = :cdn_proxy
  # ...
```



```ruby
# config/environments/test.rb
# ..
# no changes
# ..
```


```ruby
# config/environments/development.rb
# ..
# no changes
# ..
```



```ruby
# config/routes.rb
# ...
  direct :cdn_proxy do |model, options|
    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id,
        model.filename,
        options.merge(host: Rails.configuration.x.cdn_host)
      )
    else
      signed_blob_id = model.blob.signed_id
      variation_key  = model.variation.key
      filename       = model.blob.filename
      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options.merge(host: Rails.configuration.x.cdn_host)
      )
    end
  end
# ...
```


Tested and works with Rails 6.1

* [Official Active Storage docs - CDN](https://edgeguides.rubyonrails.org/active_storage_overview.html#putting-a-cdn-in-front-of-active-storage)
* [Official Active Storage docs - Proxy mode](https://edgeguides.rubyonrails.org/active_storage_overview.html#proxy-mode)


### Set up CDN

Point your CDN origin URL to point to root of your apps URL.

E.g. if your app is `https://www.myapp.com` CDN origin will point to `https://www.myapp.com/`

* `https://myapp-prod.b-cdn.net/rails/active_storage/representations/proxy/xxxxxx/example.jpg` -> `https://www.myapp.com/rails/active_storage/representations/proxy/xxxxxx/example.jpg`
* `https://myapp-stg.b-cdn.net/rails/active_storage/representations/proxy/xxxxxx/example.jpg`  -> `https://staging.myapp.com/rails/active_storage/representations/proxy/xxxxxx/example.jpg`

## Sources

* <https://discuss.rubyonrails.org/t/putting-a-cdn-in-front-of-activestorage/76948/4>
* <https://github.com/rails/rails/issues/35926>
* <https://github.com/rails/rails/pull/42305>
* <https://github.com/rails/rails/pull/42363/files>
* <https://lipanski.com/posts/activestorage-cdn-rails-direct-route> out of date article (don't use)
