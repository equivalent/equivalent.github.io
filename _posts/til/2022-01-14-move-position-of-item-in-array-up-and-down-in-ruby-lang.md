---
layout: til_post
title:  "Move position of item in Array up and down in Ruby lang"
categories: til
disq_id: til-93
---

```ruby
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

```ruby
require 'spec_helper'
#  require 'rails_helper' if you use Rails spec

RSpec.describe ArrayElementMove do
  let(:arr) { [1,2,3,4,5,6] }

  it do
    ArrayElementMove.up!(arr, 4)
    expect(arr).to eq([1,2,4,3,5,6])

    expect(ArrayElementMove.up!(arr, 4).to eq([1,4,2,3,5,6])
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

reference:

* <https://stackoverflow.com/questions/4733925/how-to-change-the-position-of-an-array-element/70717052#70717052>
