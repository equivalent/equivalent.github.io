---
layout: til_post
title:  "Exporting and Importing large amount of data in Rails"
categories: til
disq_id: til-56
---

Couple of days ago my colleague and I we were creating export / import script to migrate several hundred
thousand records and associated relations from one Ruby on Rails application to
another Ruby on Rails application (with bit different data model).

E.g. something like this:

```
Product
  - Media
    - Attachment   # e.g. paperclip or carrierwave
  - Comments
```

It doesn't really matter what is the structure of the data as the main
problem was the "speed" of the export / import script and transparency of the data.

There are couple of ways how to this export and I'll describe other
techniques in section bellow. But it this TIL note I want to mainly
focus on solution with **IO stream**:

##### export script

```ruby
class Export
  def call
    file = File.open(Rails.root.join('tmp/export_products.txt'), 'w')

    Product.find_each do |product|
      file.write(serialize_product(product).to_json)
      file.write("\n")
    end

    file.close
  end

  private

  def serialize_product(product)
    {
      id: product.id
      title: product.title
      created_at: product.created_at
      comments: product.comments.map { |c| serialize_comment(c) }
      media: product.media.map { |m| serialize_medium(m) }
    }
  end

  def serialize_comment(comment)
    {
      id: comment.id,
      content: comment.content,
      created_at: comment.created_at,
    }
  end

  def serialize_medium(medium)
    {
      id: medium.id,
      attachment_original_size: medium.attachment.url(:original)
      attachment_thumb_size: medium.attachment.url(:thumb)
    }
  end
end

Export.new.call
```

this will export something like:

```json
{"id": 1, "title": "Apple youPhone", "comments": [{"id":10, "content": "How dare you?\\n Don't you know apples are fruit?"}], "media":[{"id": 11, "attachment_original_size":"http://xxxx.jpg", "attachment_thumb_size":"http://yyyy.jpg", }]
{"id": 2, "title": "Trivium", "comments": [], "media":[{"id": 12, "attachment_original_size":"http://tttt.jpg", "attachment_thumb_size":"http://rrrr.jpg", }]
{"id": 3, "title": "Bring me the Horizon", "comments": [{"id":13, "content": "Scream"}], "media":[]
```

As you can see it's a text file that contains JSON object on every line
representing a data set items.

Important points

* we use Rails built in `Rails.root.join('tmp/export_products.txt')`  to
point to `project_directory/tmp/export_products.txt`
* `Product.find_each` ActiveRecrod [#find_each](https://apidock.com/rails/ActiveRecord/Batches/ClassMethods/find_each) will load all the Product records
in chunks of 1000 records at a time. So unlike `Product.all.each` (which
would load all records to the memory ) it
will consume less memory for export script
* `serialize_product(product).to_json` we are converting the Product
record to Ruby hash of fields that we want to export ( `{:id=> 1, :title =>
"hello"}` and then we are converting that to JSON `{"id": 1, "title":
"hello"}`
* `file.write "\n"` to create the new line separation

> note: use `Product.with_deleted.find_each do |product|` if you use
> [Act as paranoid gem](https://github.com/ActsAsParanoid/acts_as_paranoid)

> note2: if you ever need "in groups" version of `find_each` you can use `Product.find_in_batches { |batch| puts "batch"; batch.each { |product| puts product.id } } `

##### Import script

```ruby
require 'json'
require 'uri'

class Import
  def call
    IO.foreach(Rails.root.join('tmp/export_products.txt')) do |product_json_line|
      product_hash = JSON.parse(product_json_line)
      create_product(product_hash)
    end
  end

  private

  def create_product(product_hash)
    product = Product.new
    product.old_version_id = product_hash.fetch('id')
    product.title = product_hash.fetch('title')
    if product.save
      product_hash['media'].each do |media_hash|
        medium = product.media.new
        medium.old_version_id = media_hash.fetch('id')
        medium.file = URI.open(media_hash.fetch('attachment_original_size'))
        unless medium.save
          logger.info("product #{product_hash['id']} medium #{media_hash.fetch('id')} was not created ")
        end
      end

      product_hash['comments'].each do |comments_hash|
        # ...
      end
    else
      logger.info("product #{product_hash['id']} was not created")
    end
  end

  def logger
    return @logger if @logger
    @logger = Logger.new(Rails.root.join('log/import.log'))
    @logger.level = 0 # debug level
    @logger
  end
end

Import.new.call
```

Important points:

* We use `IO.foreach(file_path) do |line|` which will "stream" every line to the block. If we use `File.readline(file_path) do |line|` or `File.read(file_path).split("\n") do |line|` we would have to load the entire content to memory (and like I've said this solution needs support migration of few GB size file of data).
To learn more read [this article](https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html)
* Then we are parsing the line from JSON to Ruby hash with `JSON.parse(line)`.
* we use `hash.fetch('key')` rather than `hash['key']` as the fetch will raise exception if the key is missing (where as `hash['key']` would return nil if key is missing). Now given the script will run couple of hours / days you don't want to discover at the end of it that some data have `nil` values only after it finish. Fail early!
* We log errors with [Ruby logger](https://ruby-doc.org/stdlib-2.1.2/libdoc/logger/rdoc/Logger.html) to custom `import.log` file. It's easier to debug when it's a separate file.
* export script exported the url to the file fore the Medium (e.g.: `http://test.jpg`) now we will use ` URI.open('http://test.jpg')` to download the file and save it to new storage (e.g. [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html). Now you may point out that we are importing only `attachment_original_size` and not the `attachment_thumb_size`. This is because I would recommend to recreate the "thumbnails" from the original (as with smaller files it's faster then download). But it's up to your business logic if you want to download the thumbnails or recreate them (e.g. large pictures or video thumbnails).


Now one more recommendation. Sometimes you don't want to import data
partially. If the Product was created and Medium failed you may want to
remove the Product. What you can do is wrap it with transaction:

```ruby
def create_product(product_hash)
  Product.transaction do
    begin
      product = Product.new
      product.old_version_id = product_hash.fetch('id')
      product.title = product_hash.fetch('title')
      product.save!
      product_hash['media'].each do |media_hash|
        begin
          medium = product.media.new
          medium.old_version_id = media_hash.fetch('id')
          medium.file = URI.open(media_hash.fetch('attachment_original_size'))
          medium.save!
        rescue => e
          logger.info("product #{product_hash['id']} medium #{media_hash.fetch('id')} was not created: #{e} ")
        end
      end
    rescue => e
      logger.info("product #{product_hash['id']} was not created: #{e}")
    end
  end
end
```

... now it really depends if this is the right choice for your situation
as this way you will prevent partial data from being migrated but opening Transactions for long time on production DB server may not be
good choice as it could slow down user experience accessing the
application.


> Source of the IO trick is from article [Fast file processing Ruby](https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html)
>
>You can do lots of crazy stuff with `\n` sparated lines, like lazy loading:
> `IO.foreach('large.txt').lazy.grep(/abcd/).take(10).to_a`

## Other solutions

#### CSV export

You could export individual database tables to CSV and then just join
them by ids:

```ruby
require 'csv' # standard Ruby lib

# export
CSV.open('products.csv', 'w') do |csv|
  csv << ['id', 'title']   # column names
  Product.find_each |do| |product|
    csv << [product.id, product.title]
  end
end

CSV.open('commens.csv', 'w') do |csv|
  csv << ['id', 'product_id', 'attachment_original_size', 'attachment_thumb_size']   # column names
  Medium.find_each |do| |medium|
    csv << [
      medium.id,
      medium.product_id,
      medium.attachment.url(:original),
      medium.attachment.url(:thumb),
    ]
  end
end

# import
CSV.foreach('products.csv', headers: true) do |p_hash|
  product = Product.new
  product.old_version_id = p_hash.fetch('id')
  product.title = p_hash.fetch('title')
  product.save!
end

CSV.foreach('medium.csv', headers: true) do |m_hash|
  product = Product.find_by!(id: m_hash.fetch('product_id'))
  medium = product.media.new
  medium.old_version_id = m_hash.fetch('id')
  medium.file = URI.open(media_hash.fetch('attachment_original_size'))
  medium.save!
end
```

In my experience when it comes to data relations this is not the best option as you need
to guarantee parent data exist before you run script to import child
relations.
You could implement logging solution but it's still hard to debug.


> Note CSV supports lot of options. E.g.: `CSV.foreach('/tmp/products.csv, headers: true, encoding: 'iso-8859-1:utf-8', skip_lines: /^(?:,\s*)+$/, converters: [(strip_whitespace = ->(f) { f ? f.strip : nil })])`

#### YAML.store or PStore

Ruby include [YAML store](https://ruby-doc.org/stdlib-2.4.0/libdoc/yaml/rdoc/YAML/Store.html) for marshaling objects to YAML format or faster 
[PStore](https://ruby-doc.org/stdlib-1.9.2/libdoc/pstore/rdoc/PStore.html)

Both solution have similar concept:

```ruby
# export
require 'yaml/store'

def product_hash(product)
  hash = { id: product.id, id: product.title }
  hash.merge! product.media.map do |medium|
    { ... } #media data
  end
  hash.merge! product.comments.map do |comment|
    { ... } #comment data
  end
  hash
end

store = YAML::Store.new(Rails.root.join('tmp/products.yaml'))
store.transaction do
  store[:products] = []
end

Product.find_each do |product|
  store.transaction do
    store[:products] << product_hash(product)
  end
end

# import
store = YAML::Store.new(Rails.root.join('tmp/products.yaml'))
store.transaction(true) do
  store[:products].each do |product_hash|
      # ...
  end
end
```

The benefit of this solution is that you store data in `yaml` so it's
easy to debug. With PStore you store it in custom binary format which is
bit faster thas YAML store but simmilar.

The downsite is that overal this is super dooper slow. YAML strore and
PStore was not designed for large quantity of data (it's a store =
database). Exporting 10 000
records will take few hours.

#### Transient DB

You could migrate data to MongoDB or to some joint DB like AWS dynamo
DB. Ten you would just point to this DB with Export and Import
application scripts. It really depends how much effort you want to invest to
this.
