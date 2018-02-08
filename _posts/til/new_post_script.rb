require 'inputs'
require 'date'

topic = Inputs.name("What is the name of the article ?")

sanitized_topic = topic.downcase.gsub(/\s/,'-').gsub(/[^\w_-]/, '').squeeze('-')

@time = Time.now

filename = "#{@time.to_date}-#{sanitized_topic}.md"


template = <<EOF
---
layout: til_post
title:  "#{topic}"
categories: til
disq_id: til-99
---

```ruby

```

EOF

filepath = "#{filename}"
File.write(filepath, template)

puts "vim #{filepath}"
