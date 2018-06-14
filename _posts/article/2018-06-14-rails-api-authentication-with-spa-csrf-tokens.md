---
layout: article_post
categories: article
title:  "Rails CSRF protection for SPA"
disq_id: 51
description:
  How to secure Rails API for SPA with CSRF protection. Is it needed for JWT ? Or just for session cookies?
---


Topic of SPA (Single Page Applications like React) and Ruby on Rails as an API only is around for a while.
This Frontend & Backend split inspired lot of other technology
approaches like JWT (JSON Web Tokens)

But there is quite lot of confusion around security. One of the biggest
topics is CSRF (Cross Site Request Forgery).

I've already wrote an article on the topic before why it is needed in SPA that uses sessions
( [CSRF protection on single page app API](https://blog.eq8.eu/article/csrf-protection-on-single-page-app-api.html) )
but really didn't provide any "how to" guide.

Let's fix this in this article. All the methods mentioned here are
equally valid it just really depends on the usecase your application
needs.

> Special thanks goes to [johnunclesam](https://github.com/johnunclesam) for
> asking me about
> [this topic](https://github.com/equivalent/scrapbook2/issues/10#issuecomment-393104531)
> My answer was formed into this article.



## Recap on how CSRF works

```
Given I'm a user of my-bank.com
And I'm signed in to my-bank.com (cookie session id / cookie JWT)
When I click on a malicious link (email, `<img src="...">`, 3rd party website) with url `https://my-bank?transfer_all_my_money_to_user=1234`
Then all my money ends up transfered to hacker user 1234
```

The whole point of CSRF token protection is that because of cookie
session_id (or cookie with JWT) is sent on every request therefore we need one more
information (CSRF token) that server will acknowledge as browser action
by user not by malicious link.

> GET requests are not CSRF protected in Rails because it's not
> common to do "actions" like "transfer all my money" with GET requests.
> This is just simple example.

So this leaves us to the point where should the CSRF be stored ?

In HTML rendering Rails application  the CSRF token is rendered in
Rails form as a hidden field therefore it's send automatically when HTML forms are submitted.

```erb
<%= form_for @user do |f| >
  # ....
<% end %>
```

Rails HTML render will also render the CSRF token in the  `<meta name="csrf-token" ...>` tag 
so when it comes to AJAX  or SPA rendered from Rails we just
configure them to pick up the CSRF token from `<meta>` tag and send it with the AJAX request.


```erb
<html>
  <head>
    <%= csrf_meta_tags %>
```

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/rails-rendering-spa.png)


This CSRF token is generated once and used trough out of lifecycle of session:

> Rails will appear to generate a new CSRF token on every request, but it
> will accept any generated token from that session. In reality, it is
> just masking a single token using a one-time pad per request, in order
> to protect against SSL BREACH attack. More details at
> <https://stackoverflow.com/a/49783739/2016618>. You don't need to
> track/store these tokens.
>
> source: <https://stackoverflow.com/a/50225227/473040>


When it comes to API only Ruby on Rails application where SPA is not
rendered by Rails (separate server serving static files) we don't have this
luxury of `<mata>` tag.


![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2018/spa-is-independent-of-rails-api.png)

Therefore we need to provide the CSRF token to SPA some different way.

### SPA scenario: Should I store CSRF in a cookie ?

Nature of cookies is that they are sent on every request BUT Rails is
not stupid and is checking the CSRF token from `X-CSRF-TOKEN` header and
not cookie.

Lets look inside the [source_code](https://github.com/rails/rails/blob/e7feaff70f13b56a0507e9f4dfaf3ebc361cb8e6/actionpack/lib/action_controller/metal/request_forgery_protection.rb#L102)

```ruby
# inside the `protect_from_forgery` method this method is activated:
# ...
def verified_request?
  !protect_against_forgery? || request.get? || request.head? ||
    valid_authenticity_token?(session, form_authenticity_param) ||
    valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
end
# ...
```

 So in theory
if you store the CSRF token  in a cookie
**it will not be read by server**. Therefore it should be ok.

> It doesn't matter if the server (Rails) set the cookie or the SPA
> (Angular, React, ...) set the cookie

The SPA just needs to send the CSRF as a header `X-CSRF-Token`.

Only way how the cookie CSRF store would be dangerous is if you write
your own CSRF token validation that would look something like this (**So don't do this!**):

```ruby
class MyController < ApplicationControlle
  def transfer_all_my_money
    raise 'CSRF token invalid' unless valid_authenticity_token?(session, cookie[:csrf_token])  # seriously never do this !!!!
    # ....
  en
end
```

> So remember, CSRF tokens should be sent via a header `X-CSRF-Token`. You need
> to configure your SPA to read the CSRF token from Local storage / Cookie
> and send it as this header.


You can configure your Rails application to set CSRF token in a
cookie after login:

```ruby
class LoginController < ApplicationController
  def create
    if user_password_match
      # ....
      cookie[:my_csrf_token]= form_authenticity_token
    end
  end
end
```

Or after every Post action

```ruby
class ApplicationController < ActionController::Base

  after_action :set_csrf_cookie

  def set_csrf_cookie
    cookies["my_csrf_token"] = form_authenticity_token
  end
end
```

I however prefer CSRF as JSON API Body response which I'll describe in
next section.

## Session Id Cookie + CSRF as JSON API Body response

Other way is to provide CSRF after login as a body of the response. Single page app
Angular, React, ...) stores it somewhere(Cookie/Local storage) and send it with every request as a header.

> If you use something like Devise for login, Devise will set session
> cookie after login. What you can do is to override the sessions
> controller in a way that we will provide
> CSRF token in response:

```
curl POST  https://api.my-app.com/login.json  -d "{"email":'equivalent@eq8.eu", "password":"Hello"}"  -H 'ContentType: application/json'

# Cookie with session_id was set

response:

{  "login": "ok", "csrf": 'yyyyyyyyy" }

next request:

curl POST  https://api.my-app.com/transfer_my_money  -d "{"to_user_id:":"1234"}"  -H "ContentType: application/json" -H "X-CSRF-Token: yyyyyyyyy"
```

#### Refresh CSRF on every request

You may work for a "super secure" project where your user should interact with
your website only in one browser tab/window from one IP location. Rails CSRF is NOT designed for this ([read more](https://stackoverflow.com/questions/47723379/why-does-the-csrf-token-in-rails-not-prevent-multiple-tabs-from-working-properly))

CSRF token is valid during the lifetime of the session ([source](https://stackoverflow.com/questions/7744459/rails-csrf-tokens-do-they-expire))

If you need to ensure that every token will be valid for only one
request (a.k.a: [Non transferable tokens](https://github.com/equivalent/scrapbook2/blob/master/security_notes.md#authenticated-sessions-should-not-be-transferable-or-should-they-)) you will have to implement custom solution where you would
create table of whitelisted per-user-tokens and either set that token  in another cookie or provide it with every response of any request:

```
curl POST  https://api.my-app.com/transfer_my_money  -d "{"to_user_id:":"1234"}"  -H "ContentType: application/json" -H "Prev-Token: yyyyyyy"

response:
{
  "status": "ok",
  "next_token": "zzzzzzzz"
}
```

But this is not topic of this article.

## SPA with JWT token via Authentication Header

Most ideal solution is not to store any authentication cookie and send JWT token (or
other form of token) as an `Authentication` header with every requests.

**No Cookie Authentication == No need for CSRF**

* <https://security.stackexchange.com/questions/170388/do-i-need-csrf-token-if-im-using-bearer-jwt>
* <https://security.stackexchange.com/questions/166724/should-i-use-csrf-protection-on-rest-api-endpoints/166798#166798>

Problem of authentication cookies is that they are sent on every
request. This way if your SPA needs to set the `Authentication` header you cannot just
accidentally click on malicious link that would made the request with
the `Authentication` header.


```ruby
class ApplicationController
  # no need for `protect_from_forgery`
  before_action :authenticate

  # will check if `Authentication` header `Bearer: xxxxxxx.xxxxxx.xxxx` is valid
  def authenticate
    auth_header_value = request.header[:Authorization]
    jwt_token = auth_header_value.split(' ').last
    JWT.decode jwt_token, # ...
    # ...
  end
```

Login request

```
curl POST  https://api.my-app.com/login.json  -d "{"email":'equivalent@eq8.eu", "password":"Hello"}"  -H 'ContentType: application/json'

response:

{ "login": "ok", "jwt": "xxxxxxxxxxx.xxxxxxxx.xxxxx" }
```

Subsequent request of the SPA would be:

```
curl POST  https://api.my-app.com/transfer_my_money  -d "{"to_user_id:":"1234"}"  -H "ContentType: application/json" -H "Authentication: Bearer xxxxxxxxxxx.xxxxxxxx.xxxxx"
```

If someone would send you a malicious link to `https://api.my-app.com/transfer_my_money` it would not contain the header !

There are also other benefits of not using cookie authentication:

* Backend API only application should NOT be telling  SPA
  how to store any information. This way we will give full responsibility to the SPA on
  "how to store" token and how to set the header. Rails application will only look
  at request header `Authentication` for the token.
* Cookies are Domain locked. If you need to create microservices
  that communicate with multi domain with same JWT you cannot do that with
  cookies.

But remember just one important thing. Just because you have no CSRF
issue it doesn't mean that Cross Site Scripting cannot steal this token !
You just solved one of the security issues not all of them.

Also remember that you need to have your trafic `https` only ! Never
ever send your `Authentication` header over `http` connection (read more: [Enforcing HTTPs in Rails app](https://blog.eq8.eu/article/force_ssl_is_different_than_force_ssl.html)).

### Sources

* <https://github.com/equivalent/scrapbook2/issues/10#issuecomment-393104531>
* <https://stackoverflow.com/questions/50159847/single-page-application-and-csrf-token>
* <https://stackoverflow.com/questions/47723379/why-does-the-csrf-token-in-rails-not-prevent-multiple-tabs-from-working-properly/49783739#49783739>
* <https://stackoverflow.com/questions/50134071/authenticate-apis-for-all-clients-type-with-one-or-many-methods>
* <https://stackoverflow.com/questions/20504846/why-is-it-common-to-put-csrf-prevention-tokens-in-cookies>
* <https://stackoverflow.com/questions/1336126/does-every-web-request-send-the-browser-cookies>
* <https://www.owasp.org/index.php/HttpOnly>
* <https://github.com/equivalent/scrapbook2/blob/master/security_notes.md#use-secure-cookies>
* <http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html#method-i-protect_from_forgery>
* <https://github.com/rails/rails/blob/e7feaff70f13b56a0507e9f4dfaf3ebc361cb8e6/actionpack/lib/action_controller/metal/request_forgery_protection.rb#L102>
* <https://stackoverflow.com/questions/8503447/rails-how-to-add-csrf-protection-to-forms-created-in-javascript>
* <https://security.stackexchange.com/questions/170388/do-i-need-csrf-token-if-im-using-bearer-jwt>
* <https://security.stackexchange.com/questions/166724/should-i-use-csrf-protection-on-rest-api-endpoints/166798#166798>
* <https://stackoverflow.com/questions/47723379/why-does-the-csrf-token-in-rails-not-prevent-multiple-tabs-from-working-properly>
* <https://stackoverflow.com/questions/7744459/rails-csrf-tokens-do-they-expire>

Related article: [CSRF protection on single page app API](https://blog.eq8.eu/article/csrf-protection-on-single-page-app-api.html)

Related discussions:

* <https://twitter.com/equivalent8/status/1007366289336291328>
* <https://www.reddit.com/r/ruby/comments/8r55qf/rails_api_csrf_protection_for_spa/>
