---
layout: til_post
title:  "Content-Type application/json by default in Rails 5"
categories: til
disq_id: til-47
---

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

