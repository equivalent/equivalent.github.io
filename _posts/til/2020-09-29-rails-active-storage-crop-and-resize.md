---
layout: til_post
title:  "Rails ActiveStorage - crop and resize image variant"
categories: til
disq_id: til-76
---



[Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.htm) image [variants](https://api.rubyonrails.org/classes/ActiveStorage/Variant.html) can run on two different engines: MiniMagic/Imagemagic  or ruby-vips/`libvips` which variant options have different syntax. The following will work for **MiniMagic/Imagemagic** setup:

> tested on Rails 6.0.3.2 Ruby 2.7.1 on 2020-09-29

```ruby
class Medium < ApplicationRecord
  has_one_attached :image
end
```

Let say we upload an image


```ruby
medium = Medium.create(params.require(:medium).permit(:image))
```

> Here is the [original image](/assets/2020/as-crop-original.jpg). Size is `1024x4246`

```ruby
medium.image.variant({ combine_options: { resize: "400x300^",  crop: '400x300+0+0' }})
```

![Result](/assets/2020/as-crop-resize-1.jpg)


Order of combine options does matter !!! If I swap resize and crop this will happen

```ruby
medium.image.variant({ combine_options: { crop: '400x300+0+0', resize: "400x300^" }})
```

![Result](/assets/2020/as-crop-resize-2.jpg)


If you want to center

```ruby
medium.image.variant({:combine_options=>{:gravity=>"Center", :resize=>"400x300^", :crop=>"400x300+0+0" }})
```

![Result](/assets/2020/as-crop-resize-3.jpg)


If you need to rotate/auto-orient image:

```ruby
medium.image.variant({:combine_options=>{:auto_orient=>true, :rotate=>"0", :gravity=>"Center", :resize=>"400x300^", :crop=>"400x300+0+0" }})
```

As For `libvips` yes you can do the same thing but I don't have code to
paste here. I'll update this article once I have.

### Discussion

* <https://www.reddit.com/r/ruby/comments/j21kv8/rails_activestorage_resize_and_crop_image_variant/>
