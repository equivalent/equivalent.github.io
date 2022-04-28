---
layout: til_post
title:  "How to use Bootstrap 5 in Rails 7 - importmaps & sprockets"
categories: til
disq_id: til-99
---


Rails 7 is breath of fresh air. Thanks to
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

```
// app/javascript/application.js
// ...
import 'bootstrap'
```


> Note: For some reason popperjs acts broken in my Rails7 project  when I load it from
> default `ga.jspm.io` CDN. That's why I recommend to load it from `unpkg.com`:

```
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

```
// app/assets/stylesheets/application.scss
// ...
@import "bootstrap";
// ...
```


If you want to change some variables:


```
// app/assets/stylesheets/application.scss
// ...
$primary: #c11;
@import "bootstrap";
// ...
```

* [list of all variables](https://github.com/twbs/bootstrap-rubygem/blob/master/assets/stylesheets/bootstrap/_variables.scss)
* [advanced way how to change variables](https://github.com/twbs/bootstrap-rubygem/issues/210)


### Alternative solutions

* you can use the `rails new --css bootstrap` option but that will
require `esbuild` which requires all the JS shenanigans in your laptop this article wants to
avoid
* [gem bootstrap and importmaps to load vendor javascript in the gem](https://dev.to/coorasse/rails-7-bootstrap-5-and-importmaps-without-nodejs-4g8) - good solution if you want to avoid CDN


### Sources

* [Learn more on importmaps - DHH video](https://www.youtube.com/watch?v=PtxZvFnL2i0)

### Discussion



