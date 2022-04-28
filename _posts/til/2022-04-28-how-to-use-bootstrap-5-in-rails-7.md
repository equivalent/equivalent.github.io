---
layout: til_post
title:  "Simple way how to use Bootstrap 5 in Rails 7 - importmaps & sprockets"
categories: til
disq_id: til-95
---


Rails 7 is a breath of fresh air. Thanks to
[importmaps](https://github.com/rails/importmap-rails) everything is
simple again. JavaScript (JS) is easy to be implemented without the need
to install node,npm,yarn,webpack,..other 150 non-Ruby tools on your Laptop

But what about CSS ?

Well there is good old  Sprockets (a.k.a [Rails asset pipeline](https://guides.rubyonrails.org/asset_pipeline.html)) and good old gems contanining SCSS (remember those?)

Let's make life easy again

### Instalation of Bootstrap 5 in Rails 7

#### JavaScript (JS)

If you don't have [importmaps](https://github.com/rails/importmap-rails) yet in your Rails project: 

```bash
# to check if you already have importmaps 
$ cat config/importmap.rb

# to install importmaps in your Rails7 project
$ rails importmap:install
```

To add Bootstrap 5 JS to Rails 7 project via importmaps:

```
$ bin/importmap pin bootstrap
```

...this will add necessary JS (bootstrap and popperjs)  to `config/importmaps.rb`

Then you need to just import bootstrap in your `application.js`

```js
// app/javascript/application.js
// ...
import 'bootstrap'
```


> Note: For some reason popperjs acts broken in my Rails7 project  when I load it from
> default `ga.jspm.io` CDN. That's why I recommend to load it from `unpkg.com`:

```ruby
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.1.3/dist/js/bootstrap.esm.js"
pin "@popperjs/core", to: "https://unpkg.com/@popperjs/core@2.11.2/dist/esm/index.js" # use unpkg.com as ga.jspm.io contains a broken popper package
```


#### CSS (JS)

To install official
[Bootstrap 5 Ruby gem](https://github.com/twbs/bootstrap-rubygem) 


```ruby
# Gemfile
# ...
gem 'bootstrap', '~> 5.1.3'
# ...
```

and `bundle install`


Then just edit your `app/assets/stylesheets/application.scss`

```scss
// app/assets/stylesheets/application.scss
// ...
@import "bootstrap";
// ...
```


If you want to change some variables:


```scss
// app/assets/stylesheets/application.scss
// ...
$primary: #c11;
@import "bootstrap";
// ...
```

* [list of all variables](https://github.com/twbs/bootstrap-rubygem/blob/master/assets/stylesheets/bootstrap/_variables.scss)
* [advanced way how to change variables](https://github.com/twbs/bootstrap-rubygem/issues/210)


#### Layout files


Make sure your layout (`app/views/application.html.erb`) contains:

```erb
<%# ... %>
<head>
<%# ... %>
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>  <%# this loads Sprockets/Rails asset pipeline %>
    <%= javascript_importmap_tags %> <%#  this loads JS from importmaps %>
    <%# ... %>
  </head>
  <!-- ... -->
```



### Alternative solutions

* [gem bootstrap and importmaps to load vendor javascript in the gem](https://dev.to/coorasse/rails-7-bootstrap-5-and-importmaps-without-nodejs-4g8) - good solution if you want to avoid CDN
* you can use the `rails new --css bootstrap` option but that will
require `esbuild` which requires all the JS shenanigans in your laptop this article wants to
avoid
* you can use [webpacker](https://guides.rubyonrails.org/webpacker.html) but again you need node,yarn,... So, have fun

### counterarguments

> "but this way you load a gem and you don't use the JS bit of it"

So what? Like if there's no single gem in your project you don't use at 100%. I love "vanilla Rails" approach and
love to avoid 3rd party gems as much as I can but this will save you so
much hustle, especially if you are a beginner new to Rails or you are
starting a sideproject (there's always a time to refactor if you really
need to)

> "but Sprockets are no longer used"

Yes they are. There was a period of time with RoR 5.2 & 6.x where webpacker
was taking over and developers were ditching Rails asset pipeline but
this new importmaps approach is fresh breath to bring gems with scss
back. Basecamp (& DHH) were quite clear about it that Sprockets will not
disappear  anyday soon.

> but `--css` (esbuild) is there to replace sprockets

No it's not, same way how webpacker didn't replace it

> But what if CDN provider goes down, then my application JS will not work

Yes you and other billion websites as well.  If your project is a bank then yeah sure use your
own CDN or load from vendor. But if your project is
startup to sell T-shirts  then I'm pretty sure everyone will
survive that 5 min downtime.

### Sources

* [Learn more on importmaps - DHH video](https://www.youtube.com/watch?v=PtxZvFnL2i0)

### Discussion

* <https://www.reddit.com/r/ruby/comments/udtsz8/how_to_use_bootstrap_5_in_rails_7_importmaps/>


