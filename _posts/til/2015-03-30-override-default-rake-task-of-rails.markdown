---
layout: til_post
title:  "Override default Rails rake task"
categories: til
disq_id: til-11
redirect_from:
  - "/tils/11/"
  - "/tils/11-override-default-rails-rake-task/"
---


```ruby
desc "this will be now a default task"
task info: :environment do
    puts 'Run rake test to test'
end

task(:default).clear.enhance(['info'])
```

source

* <http://stackoverflow.com/questions/8112074/overriding-rails-default-rake-tasks>
* <http://blog.codingspree.net/2012/04/26/overwriting_rake_spec_task.html>
