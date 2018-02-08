---
layout: til_post
title:  "Use Rails (ActiveSupport) delegation class in plain ruby"
categories: til
disq_id: til-13
redirect_from:
  - "/tils/13/"
  - "/tils/13-use-rails-activesupport-delegation-class-in-plain-ruby/"
---

```ruby
# Gemfile
source "https://rubygems.org"
gem 'active_support'
```

```ruby
require 'active_support/core_ext/module/delegation'

class Foo
  delegate :call, to: :other

  def other
    ->(){ 'foo' }
  end
end

Foo.new.call
# => 'foo'
```

source:

* <http://guides.rubyonrails.org/active_support_core_extensions.html#method-delegation>
