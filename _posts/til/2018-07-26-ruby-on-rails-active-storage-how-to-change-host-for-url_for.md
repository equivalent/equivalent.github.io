---
layout: til_post
title:  "Ruby on Rails Active Storage how to change host for url_for"
categories: til
disq_id: til-49
---

Given you use [Rails 5.2 Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html) for file uploads

```ruby
# app/models/account.rb
class Account < ActiveRecord::Base
  has_one_attached :avatar
end

# rails console
a = Account.create
a.avatar.attach(io: File.open('/tmp/dog.jpg'), filename: 'dog.jpg')
a.save

```

by default the url for active storage is set to example.com

```ruby
# rails console

app.url_for(a.avatar)
# => "http://www.example.com/rails/active_storage/blobs/xxxxxxxxxxxxxxxxxxxxxxxxxx/dog.jpg" 

app.rails_blob_url(a.avatar)
# => "http://www.example.com/rails/active_storage/blobs/xxxxxxxxxxxxxxxxxxxxxxxxxx/dog.jpg" 
```

To change the host name:

```ruby
# config/environments/developent.rb
Rails.application.routes.default_url_options[:host] = 'localhost:3000'
```

> Note: if you need to change http to https change `Rails.application.routes.default_url_options[:protocol] = 'https'`

```ruby
# rails console

app.url_for(a.avatar)
# => "http://localhost:3000/rails/active_storage/blobs/xxxxxxxxxxxxxxxxxxxxxxxxxx/dog.jpg" 

app.rails_blob_url(a.avatar)
# => "http://localhost:3000/rails/active_storage/blobs/xxxxxxxxxxxxxxxxxxxxxxxxxx/dog.jpg" 
```

> BTW there is also `rails_blob_path` helper to fetch path without host


source:

* <http://tech.sasalog.net/2018/05/use-active-storage-with-rails-5.2/>
* <https://edgeguides.rubyonrails.org/active_storage_overview.html>

### discussion

* <https://www.reddit.com/r/ruby/comments/92230l/rails_active_storage_how_to_change_host_for_url/)>
* <http://www.rubyflow.com/p/jgb3vb-ruby-on-rails-active-storage-how-to-change-host-for-urlfor>
