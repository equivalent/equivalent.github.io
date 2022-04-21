---
layout: til_post
title:  "Content-Type application/json by default in Ruby on Rails "
categories: til
disq_id: til-47
---

> note solution in this article works in Rails 5 (tested), Rails 6 (tested) Rails 7 (tested)

Imagine you generate Rails API only app (`rails new --api`) and now you want all the requset
been considered as JSON content-type (even if the header is not present in the request)

So when you do:


```bash
curl -XPOST localhost:3000/email_authentication -d '{"email": "tomas"}'
```

... it would be same as doing:

```bash
curl -XPOST localhost:3000/email_authentication -d '{"email": "tomas"}' -H 'Content-Type: application/json'
```

Rails by default has content-type: `application/x-www-form-urlencoded`


Now you may see some tutorials that poins you to just do:


```ruby
 # app/controllers/application_controller.rb
 class ApplicationController < ActionController::Base
		respond_to :json
		before_action :set_default_response_format

		private

		def set_default_response_format
			request.format = :json
		end
  # ...
```

BUT THIS WILL NOT WORK IN Rails API only app. It seems there is some middleware missing.

Long story short you can create a middleware that will translate default Rails header
to be `Content-Type: application/json` for requests:



```ruby
# config/application.rb
# ...
require './lib/middleware/consider_all_request_json_middleware'
# ...

module MyApplication
	# ...
  class Application < Rails::Application
		# ...
		config.middleware.insert_before(ActionDispatch::Static,ConsiderAllRequestJsonMiddleware)
		# ...
```

```ruby
# lib/middleware/consider_all_request_json_middleware.rb
class ConsiderAllRequestJsonMiddleware
  def initialize app
    @app = app
  end

  def call(env)
    if env["CONTENT_TYPE"] == 'application/x-www-form-urlencoded'
      env["CONTENT_TYPE"] = 'application/json'
    end
    @app.call(env)
  end
end
```

### what if I don't want api only

You may want to limit it only for certain path e.g. `/api/anything`
while keeping the rest of the app as it is

```ruby
class ConsiderAllRequestJsonMiddleware
  def initialize app
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].match(/\A\/api\/.*/) # if match /api/*
      if env["CONTENT_TYPE"] == 'application/x-www-form-urlencoded'
        env["CONTENT_TYPE"] = 'application/json'
      end
    end

    @app.call(env)
  end
end
```


### Notes for myself


In normal circumstances browser don't send any header with GET
but sends header "application/x-www-form-urlencoded" when POST PUT

When browser submits a form with file it sends  header "multipart/form-data"


Rails will parse `request.body` to `params` according to Content-Type.
So when you use value `application/json` body `{"hello":"value"}` will end up parsed
to `params` while with default `application/x-www-form-urlencoded` it
will end up ignored

So that's why FE/Browser don't necessary needs to send Content-Tye header with GET but definitelly needs to send header Content-Type=application/json with POST PUT data submissions to API (beside other things Rails  knows how that it needs to parse  request.body to JSON)

JSON is not designed to send files in the format  - we cannot do `{"file":"x03...BINARY....x4O"}`

> well we could but it would have to involve  some FE voodoo converting file to binary string == not worh it

That's why when submitting files to JSON API the format should stay "multipart/form-data"
