---
layout: til_post
title:  "Inline SVG in Ruby on Rails"
categories: til
disq_id: til-102
---

SVG image/icon has the benefit that it can be rendered as a part
of HTML rendering

```html
<!DOCTYPE html>
<html>
<head>
  <title>SVG can be inline</title>
</head>
<body>
  <h2>Here is a SVG inline 👍</h2>

  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
    <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
    <path stroke-linecap="round" stroke-linejoin="round" d="M9 9.563C9 9.252 9.252 9 9.563 9h4.874c.311 0 .563.252.563.563v4.874c0 .311-.252.563-.563.563H9.564A.562.562 0 0 1 9 14.437V9.564Z" />
  </svg>

  <p>Solution will save us extra HTTP call </p>


  <h2>Here is a SVG rendered as a regular image 😐 (non-inline)</h2>

  <img src="/assets/images/my_svg_image.svg">

  <p>
     Solution is not as good as it will create extra HTTP call.
     In 2024 not that a big deal (browser cache, CDNs, HTTP2) but still
     if you have lot of SVG images (icons) it's nice to avoid it
  </p>

</body>
</html>
```

So how to render SVG images inline in Ruby on Rails?


### Solution 1 - gem

 Best choice is to use old but very relevant and maintained gem [inline_svg](https://github.com/jamesmartin/inline_svg)

```erb
<%= inline_svg_tag("my_svg_image", height: 50, class: "red-icon" ) %>
```

### Solution 2 - render partial

But if you don't want to install another gem just to render icon you can
just render it from partial

```erb
<!-- app/views/application/_my_svg_image.html.erb -->
<svg height="<%= local_assigns[:height] %>" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M9 9.563C9 9.252 9.252 9 9.563 9h4.874c.311 0 .563.252.563.563v4.874c0 .311-.252.563-.563.563H9.564A.562.562 0 0 1 9 14.437V9.564Z" />
</svg>
```

```erb
<%= render "my_svg_image" %>
<%= render "my_svg_image", height: 50 %>
```

But once you have more icons you will find out this is difficult to maintain
as you cannot preview the icons from partials (browser, IDE,..).
Also you need to edit every partial where SVG  needs to accept HTML argument (e.g. height)


### Solution 2

So here is a solution where no extra gem is needed (given your project already uses Nokogiri) & you can preview SVG images & you can pass HTML arguments


```ruby
module SvgHelper
  SVGFileNotFoundError = Class.new(StandardError)

  def inline_svg_tag(path, options = {})
    path = Rails.root.join("app/assets/images/#{path}.svg")
    File.exist?(path) || raise(SVGFileNotFoundError, "SVG image file does not exist: #{path}")
    svg_file_content = File.binread(path)

    if options.any?
      doc = Nokogiri::XML::Document.parse(svg_file_content)
      svg = doc.at_css("svg")
      svg["height"] = options[:height] if options[:height]
      svg["width"] = options[:width] if options[:width]
      svg["class"] = options[:class] if options[:class]
      svg_file_content = doc.to_html.strip
    end

    raw svg_file_content
  end
end
```

> Note the Helper code is pretty much what [inline_svg](https://github.com/jamesmartin/inline_svg) gem does.

```erb
<%= inline_svg_tag("my_svg_image", height: 50, width: 50 class: "red-icon" ) %>
```


##### Test

```ruby
require "rails_helper"

RSpec.describe SvgHelper do
  describe "#inline_svg_tag" do
    it "raises an error when the file does not exist" do
      expect { helper.inline_svg_tag("does-not-exist") }.to raise_error(SvgHelper::SVGFileNotFoundError)
    end

    it "when no options passed returns the SVG file contents with original HTML attribute values" do
      result = helper.inline_svg_tag("my_test_svg_image")
      expect(result).to include("<svg")
      expect(result).to include('height="20"')
      expect(result).to include('width="20"')
      expect(result).not_to include("class")
    end

    it "when class option passed returns the SVG file contents with class HTML attribute" do
      result = helper.inline_svg_tag("my_test_svg_image", class: "whatever")
      expect(result).to include("<svg")
      expect(result).to include('class="whatever"')
    end

    it "when height passed returns the SVG file contents with new height" do
      result = helper.inline_svg_tag("my_test_svg_image", height: "12345")
      expect(result).to include("<svg")
      expect(result).not_to include('height="20"')
      expect(result).to include('height="12345"')
    end

    it "when width passed returns the SVG file contents with new width" do
      result = helper.inline_svg_tag("my_test_svg_image", width: "54321")
      expect(result).to include("<svg")
      expect(result).not_to include('width="20"')
      expect(result).to include('width="54321"')
    end
  end
end
```

image `app/assets/images/my_test_svg_image.svg`:

```
<svg height="20" width="20" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M9 9.563C9 9.252 9.252 9 9.563 9h4.874c.311 0 .563.252.563.563v4.874c0 .311-.252.563-.563.563H9.564A.562.562 0 0 1 9 14.437V9.564Z" />
</svg>
```

> SVG in example is outline `stop-circle` icon from <https://heroicons.com>

### why bother with SVGs

<https://www.adobe.com/creativecloud/file-types/image/comparison/png-vs-svg.html>




