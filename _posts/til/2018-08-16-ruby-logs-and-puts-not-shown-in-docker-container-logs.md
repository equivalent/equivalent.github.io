---
layout: til_post
title:  "Ruby logs and puts not shown in docker container logs"
categories: til
disq_id: til-53
---

> Capturing  Rails (or plain Ruby) logs in Docker logs output is needed when you are configuring some log agregation tool like
> Kibana that will proces logs directly from Docker container output.


Given you are using [Ruby 2.5.1 Docker image](https://hub.docker.com/_/ruby/) in Rails project, you may notice that no logs are beeing output to docker stdout (or docker compose stdout) output
even when you configure your logger to be `logger = Logger.new(STDOUT)`.

```ruby
# config/enviroments/production.rb

Rails.application.configure do
  # ...
  config.logger = Logger.new(STDOUT)
  config.level = 0
  # ...
end

Rails.logger.warn "this should appear in Docker output but it will not"

Logger.new(STDOUT).warn("this should also appear in Docker output but it will not")
```


Docker compose / docker logs output:

```bash
```

Nothing !


Not even when you do:

```ruby
docker logs -f xxxxxxxxx       # where x is docker container id

# or

docker-compose logs -f
```

Still nothing.

### Dead simple Rails Solution

> I'll explain why whis works in next section of the article

```ruby
# config/enviroments/production.rb

Rails.application.configure do
  # ...
  config.logger = Logger.new('/proc/1/fd/1')
  # ...
end

Rails.logger.warn "this will now appear in Docker output!"

Logger.new('/proc/1/fd/1').warn("this will also appear in Docker output!")
```

Docker compose / docker logs output:

```
my_app_container  | # W, [2018-08-16T06:01:00.905877 #26]  WARN -- : this will now appear in Docker output!
my_app_container  | this will also appear in Docker output!
```


### Advanced Solution

> I'll explain why whis works in next section of the article

```ruby
# irb
require 'logger'
Logger.new('/proc/1/fd/1').warn('hi')
```

Docker compose / docker logs output:

```
my_app_container  | # W, [2018-08-16T06:01:00.905877 #26]  WARN -- : hi
```


IO solution:

<https://ruby-doc.org/core-2.3.0/IO.html>


```ruby
# irb
fd = IO.sysopen("/proc/1/fd/1", "w")
a = IO.new(fd,"w")
a.sync = true # send log message immediately, don't wait
a.puts "Docker should see this"
```

Docker compose / docker logs output:

```bash
my_app_container  | Docker should see this
```

Logger with IO:

```ruby
# irb
$docker_stdout = IO.new(IO.sysopen("/proc/1/fd/1", "w"),"w")

require 'logger'
Logger.new($docker_stdout).warn('Hello from Logger')
```


Docker compose / docker logs output:

```bash
my_app_container  | W, [2018-08-16T06:18:42.449930 #40]  WARN -- : Hello from Logger
```



### How does it work

> Let me first say I may be wrong on some points here, so I'm not 100%
> sure if everything I say here is accurate.

In Ruby (and Rails as well) the `STDOUT` (and `$stdout`) stands for standard output and
it's Linux/Unix common interface for outputting messages.

The way how Linux, Unix machine works is that output of logs, IO
operations is written to `/dev/stdout`

```bash
# bash
echo "this is echo" > /dev/stdout
this is echo # this will get outputed
```

Ruby is assigning `STDOUT` and `$stdout` to Ruby `IO` object that writes
to `/dev/stdout`


> There is  also has `/dev/stderr` for error output. `STDERR` and
> `$stderr` represents that

Therefore when you initialize logger:

```ruby
# irb
require 'logger'
logger = Logger.new(STDOUT)
logger.warn "hello"
```


...you are writing to common Linux output interface pointing to
`/dev/stdout` and that what you will see on the screen.

> Ruby IO explained [here](https://robots.thoughtbot.com/io-in-ruby)


So let's investigate what the `/dev/stdout` really is in the Ruby docker
image/container:


```bash
ls -la /dev/stdout
lrwxrwxrwx 1 root root 15 Aug 15 17:56 /dev/stdout -> /proc/self/fd/1

root@4f9907039dad:/app# ls -la /dev/stderr
lrwxrwxrwx 1 root root 15 Aug 15 17:56 /dev/stderr -> /proc/self/fd/2
```

So the `/dev/stdout` is just symlink to `/proc/self/fd/1`

Therefore that is equivalent of:

```bash
echo "hi" > /proc/self/fd/1
hi  # output result
```

Ok now the thing is docker is not listening on either `/dev/stdout` (or `/dev/stderr`) or `/proc/self/fd/1`
but is listening on `/proc/1/fd/1`

```
echo "aaaa" > /proc/1/fd/1
# no output in terminal
```

Docker compose / docker logs output:

```bash
my_app_container  | aaaa
```

> I have no idea why this is, maybe so that you don't pollute your
> docker logs with any random program output.


Again this is only on Ruby Docker image ! (which is based of Ubuntu
Docker image I guess) If you are building your own Ruby docker image
from CentOS it may not be the case


More on this: <https://github.com/moby/moby/issues/19616#issuecomment-174492543>


### Alternative solutions

#### Symlink `/dev/stdout` to proper location

Theoretically you could add this to your Dockerfile:

```bash
ln -s -f /proc/1/fd/1  /dev/stdout
```

...didn't try it personally doh. I don't like the idea of everything
beyond Ruby application that uses stdout would end up in my docker logs.

#### overriding IO globally

I'm not recommending this for development or production debugging mode
as this will screw up your terminal output when typing. It works doh.
This is just so you see what I mean in my explanation:

```ruby
$stdout = IO.new(IO.sysopen("/proc/1/fd/1", "w"),"w")
$stdout.sync = true
STDOUT = $stdout

$stderr = IO.new(IO.sysopen("/proc/1/fd/1", "w"),"w")
$stderr.sync = true
STDERR = $stderr

$stdout.puts 'Message from `$stdout.puts`'
STDOUT.puts 'Message from `STDOUT.puts`'
STDERR.puts 'when error happens'

require 'logger'
Logger.new(STDOUT).warn('Hello from Logger')
```

Docker compose / docker logs output:

```
my_app-webserver_1  | Message from `$stdout.puts`
my_app-webserver_1  | => nil
my_app-webserver_1  | Message from `STDOUT.puts`
my_app-webserver_1  | => nil
my_app-webserver_1  | when error happens
my_app-webserver_1  | => nil
my_app-webserver_1  | W, [2018-08-16T06:23:43.516949 #40]  WARN -- : Hello from Logger
my_app-webserver_1  | => true
```


### Solution that I use

Common IO object for any logger beyond Rails (E.g.: Sidekiq)

```ruby
# config/application

if ENV['DOCKER_LOGS']
  fd = IO.sysopen("/proc/1/fd/1","w")
  io = IO.new(fd,"w")
  io.sync = true
  MY_APPLICATION_LOG_OUTPUT = io
else
  MY_APPLICATION_LOG_OUTPUT = $stdout
end


# config/enviroments/development.rb
Rails.application.configure do
  # ...
  config.logger = Logger.new(MY_APPLICATION_LOG_OUTPUT)
  config.level = 0
  # ...
end

# config/enviroments/production.rb
Rails.application.configure do
  # ...
  config.logger = Logger.new(MY_APPLICATION_LOG_OUTPUT)
  config.level = 1
  # ...
end

Rails.logger.warn "This will get captured in docker if the DOCKER_LOGS is set"
```

All I need to do is configure docker compose to pass variable `DOCKER_LOGS="true"`
to enable logs to `proc/1/fd/1`. This way I can use regular `rails c`
and `docker-compose up` in development environment

And if I need to print out someting to docker outside the logger I can
do it with `MY_APPLICATION_LOG_OUTPUT.puts("Important statement")`

### Discussion

Note: I may have missed some better solution or may not fully explained
reasons in full details. Any ideas or constructive criticism is
welcome. You can open a [Pull Request for this
article](https://github.com/equivalent/equivalent.github.io/blob/master/_posts/til/2018-08-16-ruby-logs-and-puts-not-shown-in-docker-container-logs.md)
or drop a comment in the discussion:

* <https://www.reddit.com/r/ruby/comments/97sofs/ruby_logs_and_puts_not_shown_in_docker_container/>
* <https://www.reddit.com/r/docker/comments/97src6/application_output_to_docker_logs_works_only_when/>
* <http://www.rubyflow.com/p/lmcfxq-ruby-logs-and-puts-not-shown-in-docker-container-logs>
