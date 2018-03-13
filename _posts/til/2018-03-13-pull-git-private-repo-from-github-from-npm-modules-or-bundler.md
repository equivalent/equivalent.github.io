---
layout: til_post
title:  "pull git private repo from github from npm modules or bundler"
categories: til
disq_id: til-44
---


### Direct password in NPM package

> This is the stupid, but pragmatic way. Somtimes you want to do this if
> you want to avoid extra cost of DevOps overhead.

With git there is a https format

```ruby
https://github.com/equivalent/we_demand_serverless_ruby.git
```

This format accepts User + password

```ruby
https://bot-user:xxxxxxxxxxxxxxxxxxxxxxxxxxx@github.com/equivalent/we_demand_serverless_ruby.git
```

So what you can do is create a new user that will be used **just as a bot**, 
add only enough permissions that he can just read the repository you
want to load in NPM modules and just have that directly in your
`packages.json` / `Gemfile`


```
Github > Click on Profile > Settings > Developer settings > Personal access tokens > Generate new token

```

In Select Scopes part, check the  on **repo**:  Full control of private  repositories

This is so that token can access private repos that user can see


Now create new group in your organization, add this user to the group and  add only repositories that you expect
to be pulled this way (READ ONLY permission !)


You need to be sure to push this config **only to private repo**



Then you can add this to your Gemfile  /  packages.json (bot-user is
name of user, xxxxxxxxx is the generated personal token)

```js
// packages.json


# ...

{
  // ....
  "name_of_my_lib": "https://bot-user:xxxxxxxxxxxxxxxxxxxxxxxxxxx@github.com/ghuser/name_of_my_lib.git"
  // ...
}

```


```ruby
# Gemfile

# ...

gem "name_of_my_gem", git: "https://bot-user:xxxxxxxxxxxxxxxxxxxxxxxxxxx@github.com/ghuser/name_of_my_gem.git"

```


source:

* <https://stackoverflow.com/questions/28728665/how-to-use-private-github-repo-as-npm-dependency>


### Sign in bundler config

If you need to avoid commiting tokens to codebase and if you can affort to alter the build process you can add github access
directly to the global bundler setup

e.g.:

```ruby
gem install bundler # after bundler was installed
bundle config github.com "bot-user:xxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

I'm pretty sure NPM has something simillar

### evaluation solution


another option is to evaluate the file like a template and insert tokens
manually

e.g.:

```ruby
# packages.json.erb

{
  // ....
  "name_of_my_lib": "https://bot-user:<%= ENV['BUILD_BOT_TOKEN'] %>@github.com/ghuser/name_of_my_lib.git"
  // ...
}

```

and just configure your build script to generate this
`packages.json.erb` to `packages.json` while evaluating those tokens in
ENV variables.

This way you don't have to commit your keys to codebase (`packages.json`
will be in `.gitignore`) but you need to generate this config file each
time you before  `npm install` run (pain in the a$$)

> again you can do same thing for bundler Gemfile (evealuate the
> template via system Ruby before `bundle install`) but it's not pretty.
