---
layout: til_post
title:  "Carrierwave uploader not triggering proces in RSpec"
categories: til
disq_id: til-10
redirect_from:
  - "/tils/10/"
  - "/tils/10-carrierwave-uploader-not-triggering-proces-in-rspec/"
---

processing is turn off for sake of test speed

```ruby
# spec/my_test.spec
before do
  DocumentUploader.enable_processing = true
end
```

It's probably because you have something like

```ruby
# config/initializers/carrierwave.rb
if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    config.storage = :fog
  end
end
```

I recommend to keep the `enable_processing = false` and just
overide it when needed
