---
layout: til_post
title:  "ImageMagic cache resources exhausted"
categories: til
disq_id: til-82
---


We are living in a age of ridiculous smartphone cameras. Chances are you
will see user uploading 108 Megapixel images and your ImageMagic
crushing when processing it.


![](https://user-images.githubusercontent.com/721990/100261456-0a7dc780-2f4b-11eb-8e04-e79e9854cffa.png)


```bash

convert source.jpg  -auto-orient -auto-orient -rotate 0 -resize 1024x1024 destination.jpg


convert-im6.q16: DistributedPixelCache '127.0.0.1' @ error/distribute-cache.c/ConnectPixelCacheServer/244.
convert-im6.q16: cache resources exhausted `source.jpg' @ error/cache.c/OpenPixelCache/3984.
convert-im6.q16: DistributedPixelCache '127.0.0.1' @ error/distribute-cache.c/ConnectPixelCacheServer/244.
convert-im6.q16: cache resources exhausted `source.jpg' @ error/cache.c/OpenPixelCache/3984.

```

## Solution

open file `/etc/ImageMagick-6/policy.xml` and change

```
    <policy domain="resource" name="disk" value="1GiB"/>
```

To

```
    <policy domain="resource" name="disk" value="8GB"/>
```


Why ?

>  Any large image is cached to disk rather than memory:


read more <https://imagemagick.org/script/security-policy.php>

### Ruby on Rails - Active Storage error


[ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html) is using ImageMagic (`convert` command as a part of `MiniMagic` gem). Therefore  this error will happen to
your production box (with same solution, increase the `disk` value in `/etc/ImageMagick-6/policy.xml`


Error similar to this  is what you get in Airbrake if you have this
issue

```
MiniMagick::Error:  `convert /tmp/ActiveStorage-351753-20201125-8-169rgj7.jpg[0] -auto-orient -auto-orient -rotate 0 -resize 1024x1024 /tmp/image_processing20201125-8-1t1nncq.jpg` failed with error: convert-im6.q16: cache resources exhausted `/tmp/ActiveStorage-351753-20201125-8-169rgj7.jpg' @ error/cache.c/OpenPixelCache/4083.
```


These files are usually large (like 17MB) so if your Web app has some
hard limit on maximum file size e.g. 8MB you should be fine.

E.g. if you use [active_storage_validations gem](https://github.com/igorkasyanchuk/active_storage_validations):

```ruby
class Image < ApplicationRecord
  has_one_attached :file

  # validations by active_storage_validations
  validates :file, attached: true,
    size: { less_than: 9.megabytes , message: 'image too large', message: 'needs to be up to 8MB' },
    content_type: { in: ['image/png', 'image/jpg', 'image/jpeg'], message: 'needs to be an PNG or JPEG image' }
```


But chances are you want to support uploads from phone and you have to
accept the fact that 20 MB Images will end up on your platform.

### Docker solution

save content of `policy.xml` to `docker_imagemagic_policy.xml` (including the fix line "disk" value increased)


```
# ...
# install image magic
RUN apt-get update -y && apt-get install -y imagemagick libmagickcore-dev libmagickwand-dev libmagic-dev && rm -rf /var/lib/apt/lists/*

# ...
# the solution
ADD ./config/docker_imagemagic_policy.xml /etc/ImageMagick-6/policy.xml
```


### Sources

* <https://github.com/ImageMagick/ImageMagick/issues/396>
* <https://stackoverflow.com/questions/31407010/cache-resources-exhausted-imagemagick>

### Discussion
