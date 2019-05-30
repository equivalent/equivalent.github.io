---
layout: til_post
title:  "How to launch Rails console in specific Docker image or  Docker container"
categories: til
disq_id: til-64
---


## docker-compose run

Given you have [docker-compose](https://docs.docker.com/compose/) e.g.

```
# docker-compose.yml
version: '3'
services:
  my_application:
    image: name_of_my_image:latest
    build:
      context: .
      dockerfile: Dockerfile
    # ...
```

`docker-compose run` will start docker image as a container. So you are able to do:

```bash
# launch interactive bash
docker-compose run -it my_application  bash

# launch interactive rails console on that rails image
docker-compose run -it my_application rails c

# or if you don't have global bundler in that rails docker image
docker-compose run -it my_application bin/rails c

# to run daemonized rake task in that rails docker image
docker-compose run -d my_application bin/rake db:migrate

# to run daemonized rails runner
docker-compose run -d my_application bin/rails runner 'User.all.find_each {|u| u.do_something! }'
```
## docker exec

Let say you are already running docker containers (e.g. via
`docker-compose up` or plain `docker run name_of_my_image`)

You are able to launch a new Rails console on existing docker container

> this will use less memory copared to  `docker-copose run`

You can do that with `docker exec -it xxxxxxx bin/rails c` (where the
`xxxxx` is container id)

> in order to get container ID you can do `docker ps` first column is
> the docker container id

But problem is the container id is different every time. What if you
want to launch command that will launch on specific docker container from
docker image named `name_of_my_image`


```bash
# launch interactive bash on that running container
docker exec -it $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bash

# launch interactive rails console on that running container
docker exec -it $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) rails c

# or if you don't have global bundler in that container
docker exec -it $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rails c

# to run daemonized rake task in the container
docker exec -d $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rake db:migrate

# to run daemonized rails runner
docker exec -d $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rails runner 'User.all.find_each {|u| u.do_something! }'
```

Sudo version

```bash
# run bash in contain
sudo docker exec -it $( sudo docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bash
sudo docker exec -it $( sudo docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rails c`

sudo docker exec -it $( sudo docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rails c`

sudo docker exec -d $( sudo docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rake db:migrate

sudo docker exec -d $( sudo docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bin/rails runner 'User.all.find_each {|u| u.do_something! }'
```

> reminder: docker containers need to run already in order to do `docker exec`. If this don't work  make sure `docker ps`  give you back some ids.


## Other

You are also able to do bulk actions (like delete dead images to free up disk) with
some bash magic. Check <https://blog.eq8.eu/article/spring-cleanup-web-developer.html> for more info

## Discussion

* <https://www.reddit.com/r/ruby/comments/busxti/how_to_lunch_rails_console_in_specific_docker/>
* <https://www.reddit.com/r/docker/comments/busymw/how_to_lunch_rails_console_in_specific_docker/>

