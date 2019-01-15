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
file = open('https://eq8.eu/some-image.jpg')

medium = Medium.last
medium.image.attach(io: file, filename: 'some-image.jpg')

# or
medium.image.attach(io: file, filename: 'some-image.jpg', content_type: 'image/jpg')
```

Or without require

```ruby
require 'uri'

file = URI.open('https://eq8.eu/some-image.jpg')

medium = Medium.last
medium.image.attach(io: file, filename: 'some-image.jpg')

# or
medium.image.attach(io: file, filename: 'some-image.jpg', content_type: 'image/jpg')
```


### Attach local file

```ruby
medium = Medium.last
medium.image.attach(io: File.open("/tmp/some-image.jpg"), filename: "some-image.jpg", content_type: "image/jpg")
```

