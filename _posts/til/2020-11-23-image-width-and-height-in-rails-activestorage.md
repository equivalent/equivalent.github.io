---
layout: til_post
title:  "How to store image width & height in Rails ActiveStorage"
categories: til
disq_id: til-80
---



According to [ActiveStorage Overview Guild](https://edgeguides.rubyonrails.org/active_storage_overview.html#analyzing-files
) there is already existing solution `image.file.analyze` and `image.file.analyze_later` ([docs](https://edgeapi.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html) ) which uses [ActiveStorage::Analyzer::ImageAnalyzer](https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html)

According to [#analyze docs](https://edgeapi.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html) :

> New blobs are automatically and asynchronously analyzed via analyze_later when they're attached for the first time.

That means Given model like this:


```ruby
class Image < ApplicationRecord
  has_one_attached :file
end
```

...you can access your image dimensions with:

```ruby
image.file.metadata
#=> {"identified"=>true, "width"=>2448, "height"=>3264, "analyzed"=>true}

image.file.metadata['width']
image.file.metadata['height']
```

So your model can look like:

```ruby
class Image < ApplicationRecord
  has_one_attached :file

  def height
    file.metadata['height']
  end

  def width
    file.metadata['width']
  end
end
```

**For 90% of regular cases you are good with this**

BUT the problem is this is "asynchronously analyzed" (`#analyze_later`) meaning you will not have the metadata stored right after upload

```ruby
image.save!
image.file.metadata
#=> {"identified"=>true}
image.file.analyzed?
# => nil

# .... after ActiveJob for #analyze_later finish

image.reload
image.file.analyzed?
# => true
#=> {"identified"=>true, "width"=>2448, "height"=>3264, "analyzed"=>true}
```

That means if you need to access width/height in real time (e.g. API response of dimensions of freshly uploaded file) you may need to do something like:


```ruby
class Image < ApplicationRecord
  has_one_attached :file
  after_commit :save_dimensions_now

  def height
    file.metadata['height']
  end

  def width
    file.metadata['width']
  end

  private
  def save_dimensions_now
    file.analyze if file.attached?
  end
end
```

> Note: there is a good reason why this is done async in a Job. Responses of your request will be slightly slower due to this extra code execution. So unless you have a good reason don't save_dimensions_now


### Test

```ruby
require 'rails_helper'
RSpec.describe Image, type: :model do

  # ...

  describe '#save_dimensions_now' do
    let(:medium) { build :medium, image: image }

    context 'when trying to upload jpg' do
      let(:image) { FilesTestHelper.jpg }

      it do
        expect { medium.save }
          .to change { medium.height }.from(nil).to(35)
      end

      it do
        expect { medium.save }
          .to change { medium.width }.from(nil).to(37)
      end
    end

    context 'when trying to upload pdf' do
      let(:image) { FilesTestHelper.pdf }

      it do
        expect { medium.save }
          .not_to change { medium.height }
      end
    end
  end
end
```

> How `FilesTestHelper.jpg` work is explained in article [attaching Active Storange to Factory Bot](https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html)

### More solutions

I was originally answering [this StackOverflow](https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html) question.
As a part of my answer I've posted this and anoter DYI solution using `ActiveStorage::Analyzer::ImageAnalyzer.new(file).metadata` via `after_commit :xxx, on: :create` saving to model DB columns if you are interested.

### Sources

* <https://stackoverflow.com/questions/60130926/activestorage-get-image-dimensions-after-upload/64929222#64929222>
* <https://edgeguides.rubyonrails.org/active_storage_overview.html#analyzing-files>
* <https://edgeapi.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html>
* <https://edgeapi.rubyonrails.org/classes/ActiveStorage/Analyzer/ImageAnalyzer.html>
* <https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html>

### Discussion

* <https://www.reddit.com/r/ruby/comments/jzpu2o/how_to_store_image_width_height_in_rails/>

