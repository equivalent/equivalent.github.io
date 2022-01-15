---
layout: article_post
categories: article
title:  "Order attachments in Rails ActiveStorage has_many_attached"
disq_id: 59
description:
  How to change order of Active Storage has_many_attached attachments
---

Ruby on Rails [Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html)  introduced
bunch of cool features for uploading files. One large advantage is a
simple way how to store multiple attachments for a model with
[has_many_attached](https://edgeguides.rubyonrails.org/active_storage_overview.html#has-many-attached) but also 
ability to upload  files with [direct upload](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads)

`has_many_attached` is a cool feature but developers may feels like it's
missing one critical feature: change order of attachments.

In this article I'll show you one simple way how to order attachments of
a simple Entry model that has many pictures.


> To limit the scope of this article I'll  assume your application have a basic setup of
> [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html)
> such as `bin/rails active_storage:install`


## Basic solution

Here is our `Entry` model. As you can see it has_many_attached `#pictures`

```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  has_many_attached :pictures

  # ...
end
```


We need to add a new Array field to the `Entry` model that will hold ids
of attached `pictures` in order. That means if attachments were uploaded
in order:

1. `ActiveStorage::Attachment id=1`
2. `ActiveStorage::Attachment id=2`
3. `ActiveStorage::Attachment id=3`

...we can store the ids `[1,2,3]` in any order we want see them appear in e.g.: `[3,1,2]`

Assuming we use **PostgreSQL database** lets add a `json` field to our
database which defalts to an empty Array

```ruby
class AddOrderedPictureIdsToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :ordered_picture_ids, :json, default: []
  end
end
```

> if you are not using Posgres database you can use Rails model
> [serialize](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html)
> field as an Array



```bash
$ bin/rails db:migrate
$ bin/rails c
```

```ruby
entry = Entry.new
entry.ordered_picture_ids
# => []
entry.ordered_picture_ids = [3,1,2]
entry.save!
entry.ordered_picture_ids
# => [3,1,2]
```


Now we will intreduce method `#ordered_pictures` which will return
`#pictures` ordered by the values in `#ordered_picture_ids`


```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  has_many_attached :pictures


  def ordered_pictures
    pictures.sort_by{ |pic| ordered_picture_ids.index(pic.id) || (pic.id*100) }
  end

  def ordered_picture_ids=(ids)
    super(ids.map(&:to_i)) # convert any ids passed to this method to integer
                           # this is just for security reasons,
                           # you don't need to do this for the feature to work
  end
end
```

> reason why we do `|| (pic.id*100)` is so that we give default order to records without explicit order (E.g stuff that was uploaded before we start changing order).  Please have a look at RSpec specs bellow to fully understand edgecases

Great now when you call `entry.ordered_pictures` you will get attached
pictures in order you like:


```slim
-# app/views/entries/edit.html.slim

- @entry.ordered_pictures.each do |picture|
  = image_tag(picture)

```


If you use some JavaScript solution (e.g drag and drop sort) that will send  an Array of ids to your backend then
this is all you need. Just update your controller to allow our new `#ordered_picture_ids` property in `params`

```ruby
class EntriesController < ApplicationController
  # ...
  def update
    entry_params = params
      .require(:entry)
      .permit(:title, pictures: [], ordered_picture_ids: [])

    @entry.attributes = entry_params

    @entry.save
    # ...
  end
end
```

## Move up and down

Rails 7 introduced [Hotwire Turbo](https://turbo.hotwired.dev/) which
makes developers that prefere  to write as little of JavaScript as
possible (like me) extremly happy.

With this technology a really elegant solution would be to have buttons that would
change order of attachments **Up** or **Down** within same turbo frame. Let's have a look how
this would look like:

#### Model

First let's introduce methods for moving attachement picture:

```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  has_many_attached :pictures

  # ...

  def ordered_pictures
    pictures.sort_by{ |pic| ordered_picture_ids.index(pic.id) || (pic.id*100) }
  end

  def ordered_picture_ids=(ids)
    super(ids.map(&:to_i))
  end

  def ordered_picture_move_up!(picture)
    ordered_picture_move!(picture, :up)
  end

  def ordered_picture_move_down!(picture)
    ordered_picture_move!(picture, :down)
  end

  private
    def ordered_picture_move!(picture, where)
      raise TypeError, "#{picture} must be a ActiveStorage::Attachment" unless picture.is_a?(ActiveStorage::Attachment)
      pics = ordered_pictures.dup
      case where
      when :up   then ArrayElementMove.up!(pics, picture)
      when :down then ArrayElementMove.down!(pics, picture)
      else
        raise "unknown option #{where}"
      end
      self.ordered_picture_ids=pics.map(&:id)
      self.save!
      self.reload
      true
    end
end
```

Methods `#ordered_pictures` and `#ordered_picture_ids` didn't change
compared to previous example.
We introduced two more methods `#ordered_picture_move_up!` and `#ordered_picture_move_down!`
that will be our interface to move items up and down.

Both uses private method `#ordered_picture_move` that will manipulate
order of pictures ids in array `#ordered_picture_ids` and save new order to
this field

> For details please see RSpec specs at the bottom of this article

Tricky bit here is how to move items up and down in a Ruby Array. As far
as I'm aware there is no built in feature directly in Ruby so I
 created a small helper `ArrayElementMove` to do that:


```ruby
# lib/array_element_move.rb
module ArrayElementMove
  MustBeUniqArray = Class.new(StandardError)
  ItemNotInArray  = Class.new(StandardError)

  def self.up!(array, item)
    self.check_if_uniq!(array)
    return array if array.first == item
    position = array.index(item) || raise(ItemNotInArray)
    array.insert((position - 1), array.delete_at(position))
  end

  def self.down!(array, item)
    self.check_if_uniq!(array)
    return array if array.last == item
    position = array.index(item) || raise(ItemNotInArray)
    array.insert((position + 1), array.delete_at(position))
  end

  def self.check_if_uniq!(array)
    raise MustBeUniqArray if array.size != array.uniq.size
  end
end
```

> more about this Class in [this til note](https://blog.eq8.eu/til/move-position-of-item-in-array-up-and-down-in-ruby-lang.html)

Don't forget to require this class in your Rails app:

```ruby
# config/application.rb
# ...
require './lib/array_element_move'
# ...
```

So this will allow us to do:

```ruby
a = [1,2,3]
ArrayElementMove.up!(a, 2)
a == [2,1,3]
```

#### Controller & views


Let's introduce seperate controller `EntryPicturesController` that will
be responsible for operations related to entry pictures (so that we don't
polute `EntryController`)

```ruby
# config/routes.rb
resources :entries do
  resources :pictures, only: [:destroy], controller: 'entry_pictures' do
    post :up,   on: :member
    post :down, on: :member
  end
end
```

```ruby
# app/controllers/entry_pictures_controller.rb
class EntryPicturesController < ApplicationController
  before_action :find_entry
  before_action :find_picture

  def up
    @entry.ordered_picture_move_up!(@picture)
    redirect_to(edit_entry_path(@entry))
  end

  def down
    @entry.ordered_picture_move_down!(@picture)
    redirect_to(edit_entry_path(@entry))
  end

  # not required, just to show why it's nice to separate concerns
  def destroy
    @picture.purge
    redirect_to(edit_entry_path(@entry))
  end

  private
    def find_entry_id
      @entry = Entry.find(params[:entry_id])
    end

    def find_picture
      @picture = @entry.pictures.find(params[:id])
    end
end
```


```slim
-# app/views/entries/edit.html.slim

= turbo_frame_for 'pictures' do
  - @entry.ordered_pictures.each do |picture|
    div.entry-picture
      = image_tag(picture)
      = button_to 'move left', up_entry_picture_path(@entry, picture)
      = button_to 'move right', down_entry_picture_path(@entry, picture)
      = button_to 'Delete', entry_picture_path(@entry, picture), method: :delete, data: {confirm: 'Delete picture?'}

```

![result](/assets/2022/reorder.gif)


That's it

## Final words

If you are here just for technical solution you don't have to read
further. I just want to close this article with some opinions.

#### Why ActiveStorage has_many_attached don't have built in ordering ?

I don't know.

I personally think this feature is missing from ActiveStorage by design
because your application may have a different iterpretation on how to
order attachments.

For example maybe within same has_many_attached your application is ordering PDFs in front of
images.

So it sounds straight forward but order logic may have many meanings

#### Wouldn't be custom Picture model better ?

So imagine we do something like:

```ruby
# app/models/entry.rb
class Entry < ApplicationRecord
  has_many :pictures
end

class Picture < ApplicationRecord
  belongs_to :entry
  has_one_attached :image
end
```

In this case our `pictures` table can be more dynamic and have an order
field upon which we can  do our re-ordering:

```ruby
# db/schema.rb
# ...
  create_table "pictures", force: :cascade do |t|
    t.bigint "entry_id"
    t.integer "order", default: 0
    # ...
```

Yes sure this is a good solution (I'm using simmilar solutions plenty in
other projects) So if it works for you go ahead. Just realize you are
giving up native ActiveStorage has_many_attached features that come
default in Rails (like no sweat direct upload). If that's not a big deal
for you then no problem.

### RSpec specs

```ruby
# spec/model/entry_spec.rb
require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe 'ordered_pictures' do
    let!(:entry) { create :entry, :with_pictures }

    before do
      @pic1, @pic2, @pic3 = entry.pictures
    end

    context 'when no exact order' do
      it do
        expect(entry.ordered_pictures).to eq([@pic1, @pic2, @pic3])
      end

      describe 'up' do
        it do
          expect(entry.ordered_pictures).to eq([@pic1, @pic2, @pic3])

          entry.ordered_picture_move_up!(@pic3)
          expect(entry.ordered_pictures).to eq([@pic1, @pic3, @pic2])

          entry.ordered_picture_move_up!(@pic3)
          expect(entry.ordered_pictures).to eq([@pic3, @pic1, @pic2])

          entry.ordered_picture_move_up!(@pic3)
          expect(entry.ordered_pictures).to eq([@pic3, @pic1, @pic2])

          entry.ordered_picture_move_up!(@pic2)
          expect(entry.ordered_pictures).to eq([@pic3, @pic2, @pic1])
        end

        it 'check type' do
          expect { entry.ordered_picture_move_up!(@pic2.blob) }
            .to raise_exception(TypeError, /ActiveStorage::Blob/)
          expect(entry.ordered_pictures).to eq([@pic1, @pic2, @pic3])
        end
      end

      describe 'down' do
        it do
          expect(entry.ordered_pictures).to eq([@pic1, @pic2, @pic3])

          entry.ordered_picture_move_down!(@pic1)
          expect(entry.ordered_pictures).to eq([@pic2, @pic1, @pic3])

          entry.ordered_picture_move_down!(@pic1)
          expect(entry.ordered_pictures).to eq([@pic2, @pic3, @pic1])

          entry.ordered_picture_move_down!(@pic1)
          expect(entry.ordered_pictures).to eq([@pic2, @pic3, @pic1])

          entry.ordered_picture_move_down!(@pic2)
          expect(entry.ordered_pictures).to eq([@pic3, @pic2, @pic1])
        end

        it 'check type' do
          expect { entry.ordered_picture_move_down!(2) }
            .to raise_exception(TypeError, "2 must be a ActiveStorage::Attachment")
          expect(entry.ordered_pictures).to eq([@pic1, @pic2, @pic3])
        end
      end
    end

    context 'when order' do
      it do
        entry.ordered_picture_ids = [@pic2.id, @pic3.id, @pic1.id]
        expect(entry.ordered_pictures).to eq([@pic2, @pic3, @pic1])
      end
    end

    context 'when order with mistakes' do
      it do
        entry.ordered_picture_ids = [@pic2.id, nil, @pic3.id, 'poop', @pic1.id]
        expect(entry.ordered_pictures).to eq([@pic2, @pic3, @pic1])
      end
    end

    context 'when order but element missing' do
      it do
        entry.ordered_picture_ids = [@pic2.id, @pic1.id]
        expect(entry.ordered_pictures).to eq([@pic2, @pic1, @pic3])
      end
    end

    context 'when order but element missing' do
      it do
        entry.ordered_picture_ids = [@pic2.id]
        expect(entry.ordered_pictures).to eq([@pic2, @pic1, @pic3])
      end
    end
  end
end
```

```ruby
# spec/lib/array_element_move_spec.rb
require 'rails_helper'
RSpec.describe ArrayElementMove do
  let(:arr) { [1,2,3,4,5,6] }

  it do
    ArrayElementMove.up!(arr, 4)
    expect(arr).to eq([1,2,4,3,5,6])

    expect(ArrayElementMove.up!(arr, 4)).to eq([1,4,2,3,5,6])
    expect(arr).to eq([1,4,2,3,5,6])

    ArrayElementMove.up!(arr, 4)
    expect(arr).to eq([4,1,2,3,5,6])

    ArrayElementMove.up!(arr, 4)
    expect(arr).to eq([4,1,2,3,5,6])
  end

  it do
    ArrayElementMove.down!(arr, 4)
    expect(arr).to eq([1,2,3,5,4,6])

    expect(ArrayElementMove.down!(arr, 4)).to eq([1,2,3,5,6,4])
    expect(arr).to eq([1,2,3,5,6,4])

    expect(ArrayElementMove.down!(arr, 4)).to eq([1,2,3,5,6,4])
    expect(arr).to eq([1,2,3,5,6,4])
  end

  context 'when non uniq array' do
    let(:arr) { [1,4,2,3,4,5,6] }

    it do
      expect { ArrayElementMove.down!(arr, 3) }.to raise_exception(ArrayElementMove::MustBeUniqArray)
      expect(arr).to eq([1,4,2,3,4,5,6])
    end

    it do
      expect { ArrayElementMove.down!(arr, 3) }.to raise_exception(ArrayElementMove::MustBeUniqArray)
      expect(arr).to eq([1,4,2,3,4,5,6])
    end
  end

  context 'when non existing item' do
    it do
      expect { ArrayElementMove.up!(arr, 9) }.to raise_exception(ArrayElementMove::ItemNotInArray)
      expect(arr).to eq([1,2,3,4,5,6])
    end

    it do
      expect { ArrayElementMove.up!(arr, 9) }.to raise_exception(ArrayElementMove::ItemNotInArray)
      expect(arr).to eq([1,2,3,4,5,6])
    end
  end
end
```


### Related articles

* <https://blog.eq8.eu/til/rails-activestorage-aws-s3-bucket-policy-permissions.html>
* <https://blog.eq8.eu/til/rails-active-storage-cdn.html>
* <https://blog.eq8.eu/til/image-width-and-height-in-rails-activestorage.html>
* <https://blog.eq8.eu/til/rails-active-storage-crop-and-resize.html>
* <https://blog.eq8.eu/til/upload-remote-file-from-url-with-activestorage-rails.html>
* <https://blog.eq8.eu/til/factory-bot-trait-for-active-storange-has_attached.html>
* <https://blog.eq8.eu/til/ruby-on-rails-active-storage-how-to-change-host-for-url_for.html>
* <https://blog.eq8.eu/til/move-position-of-item-in-array-up-and-down-in-ruby-lang.html>

### Discussion

* [Reddit](https://www.reddit.com/r/ruby/comments/s4w02y/how_to_change_order_of_attachments_in_rails/)

