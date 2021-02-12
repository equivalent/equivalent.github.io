---
layout: til_post
title:  "How to upload remote file from url with ActiveStorage Rails"
categories: til
disq_id: til-55
---

```ruby
class Medium < ActiveRecord::Base
  has_one_attached :image
end
```

### Attach remote file

with 'require open-uri'

```ruby
require 'open-uri'
file = open('https://meme.eq8.eu/noidea.jpg')

medium = Medium.last
medium.image.attach(io: file, filename: 'some-image.jpg')

# or
medium.image.attach(io: file, filename: 'some-image.jpg', content_type: 'image/jpg')
```

Or without require

```ruby
require 'uri'

file = URI.open('https://meme.eq8.eu/noidea.jpg')

medium = Medium.last
medium.image.attach(io: file, filename: 'some-image.jpg')

# or
medium.image.attach(io: file, filename: 'some-image.jpg', content_type: 'image/jpg')
```

If you want to get filename from url

```ruby
require 'uri'
uri = URI.parse('https://meme.eq8.eu/noidea.jpg')
filename = File.basename(uri.path)
```

So put all that together


```ruby
require 'uri'

url = 'https://meme.eq8.eu/noidea.jpg'

filename = File.basename(URI.parse(url).path)
file = URI.open('https://meme.eq8.eu/noidea.jpg')

medium = Medium.last
medium.image.attach(io: file, filename: filename, content_type: 'image/jpg')
```

> to get the mimetype you can use `Rack::Mime.mime_type('.jpg')` from
> the `".#{url.split('.').last}`

### Attach local file

```ruby
medium = Medium.last
medium.image.attach(io: File.open("/tmp/some-image.jpg"), filename: "some-image.jpg", content_type: "image/jpg")
```

If you want to get filename and mime_type from the file:

```ruby
filename  = File.basename("/tmp/some-image.jpg")  # => some-image.jpg
extension = File.extname("/tmp/some-image.jpg")   # => .jpg
mime_type =  Rack::Mime.mime_type(a)              #=> "image/jpeg"
```

or with Pathname

```ruby
pathname = Pathname.new('/tmp/some-image.jpg')
pathname.basename.to_s                 # => some-image.jpg
pathname.extname                       # => .jpg
Rack::Mime.mime_type(pathname.extname) # => "image/jpeg"
```

all together: 

```ruby
medium = Medium.last
pathname = Pathname.new('/tmp/some-image.jpg')

medium.image.attach(io: File.open(pathnname), filename: pathname.basename.to_s, content_type: Rack::Mime.mime_type(pathname.extname))
```

### Attach local file as a uploaded medium

Sometimes you want the file in a console to appear as it was uploaded via a
Controller.

For example if you are writing a db:seed where you attach local file you
may want to reuse bit of functionality that uses bit of controller logic:

```ruby
medium.image = params.permit(:image)
```

so Here you wont be able to do `medium.image.attach(io: File.open('...'), content_type: '...')`

Solution:

```ruby
# app/controller/media_controller.rb
# ...
  def create
    # ...
    Medium.upload_via_controller(params[:image])
    # ...
  end
end
```

```ruby
# app/models/medium.rb
class Medium < ActiveRecord::Base
  has_one_attached :image

  def self.upload_via_controller(file_from_controller)
    medium = Medium.new
    medium.image = file_from_controller
    # ...some other logic like set default order 
    medium.save
  end
end
```

```ruby
# lib/tasks/create_dummy_data.rake
module MyRakeHelper
  extend ActionDispatch::TestProcess

  def self.create_dummy_medium
    img = Rails.root.join('db/data/dummy-work.jpg')
    img = fixture_file_upload(img.to_s, 'image/jpg')

    ## ...or:
    # img = fixture_file_upload(img.to_s, Rack::Mime.mime_type(img.extname))

    Medium.upload_via_controller(img) # we want to reuse existing logic in our raketask
  end
end

task create_dummy_images: :environment do
  MyRakeHelper.create_dummy_medium
end
```

### Sources

* <https://edgeguides.rubyonrails.org/active_storage_overview.html#attaching-file-io-objects>
* <https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html>

### Related articles

* [Factory Bot trait for attaching ActiveStorange has_attached](https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html)
* [How to store image width & height in Rails ActiveStorage](https://blog.eq8.eu/til/image-width-and-height-in-rails-activestorage.html)
* [Rails ActiveStorage - crop and resize image variant](https://blog.eq8.eu/til/rails-active-storage-crop-and-resize.html)
* [change host in active storage](https://blog.eq8.eu/til/ruby-on-rails-active-storage-how-to-change-host-for-url_for.html)
