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
medium.image.attach(io: file, filename: filename)
```

### Attach local file

```ruby
medium = Medium.last
medium.image.attach(io: File.open("/tmp/some-image.jpg"), filename: "some-image.jpg", content_type: "image/jpg")
```

