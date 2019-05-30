---
layout: til_post
title:  "How to lunch Rails console in specific Docker image or  Docker container"
categories: til
disq_id: til-64
---


## docker run


`docker run` will start docker image as a container. So you are able to
do:

```bash
# lunch interactive bash
docker run -it  name_of_my_image bash

# lunch interactive rails console on that rails image
docker exec -it name_of_my_image rails c

# or if you don't have global bundler in that rails docker image
docker exec -it name_of_my_image bin/rails c

# to run daemonized rake task in that rails docker image
docker exec -d name_of_my_image bin/rake db:migrate

# to run daemonized rails runner
docker exec -d name_of_my_image bin/rails runner 'User.all.find_each {|u| u.do_something! }'
```

> you are also able to do bulk actions (like delete dead images to free up disk) with
> some bash magic. Check <https://blog.eq8.eu/article/spring-cleanup-web-developer.html> for more info

## docker exec

Let say you are already running docker containers (e.g. via
`docker-compose up`) now you don't want to `docker run` new container to
lunch a  Rails console (as that will eat up more memory) but you
rather want to execute rails commands on existing docker container.

You can do that with `docker exec -it xxxxxxx bin/rails c` (where the
`xxxxx` is container id)

> in order to get container ID you can do `docker ps` first column is
> the docker container id

But problem is the container id is different every time. What if you
want to lunch command that will lunch on specific docker container from
docker image named `name_of_my_image`


```bash
# lunch interactive bash on that running container
docker exec -it $( docker ps | grep name_of_my_image | awk "{print \$1}" | head -n 1 ) bash

# lunch interactive rails console on that running container
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

> remminder: docker containers need to run already in order to do `docker exec`. If this don't work  make sure `docker ps`  give you back some ids.

