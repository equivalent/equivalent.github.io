---
layout: article_post
categories: article
title:  "2019 set up Ubuntu 18.04 for Ruby on Rails developer (Cheatsheet)"
disq_id: 56
description:
  Quick cheatsheet  how to install various technologies for Ruby on Rails application under fresh Ubuntu 18.04 machine (2019 revised article)
---

in Nov 2016 I've published article
[Setup Ubuntu 16.04 for Ruby on Rails app (Cheatsheet)](https://blog.eq8.eu/article/setup-ubuntu-16.04.html) and
it was quite a hit. As I'm reinstalling by
[Lenovo](https://blog.eq8.eu/til/lenovo-thinkpad-e480-laptop-and-ubuntu-1604.html) with fresh Ubuntu
18.04 I've decided to write up fresh revised article related to latest
Feb 2019 technologies


## Basic tools:

```bash
sudo apt install -y curl git
```

## Generate ssh key

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

* <https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/>


## Install RVM + Ruby


* <https://rvm.io/rvm/install>
* <https://github.com/rvm/ubuntu_rvm>   RVM has official Ubuntu package now

```bash
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
sudo apt-get install software-properties-common
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm
```

As a next step RVM recommends to configure terminal to run "Login shell":

> At terminal window, click Edit > Profile Preferences, click on Title and Command tab and check Run command as login shell. [source of info](https://github.com/rvm/ubuntu_rvm#2-change-your-terminal-window)

But to be honest because I use [Cinnamon IDE](https://en.wikipedia.org/wiki/Cinnamon_(software)) I didn't have to do it it
works ok without. I just needed do a laptop restart othewise I'll get `rvm command not found`

```bash
rvm install 2.5.3
```


##  Install PostgreSQL 10.6

> at the time Postgres 11.2 is available but since AWS RDS is only
> supporting 10.6 I don't see the point going super edge.

* <https://www.postgresql.org/download/linux/ubuntu/>

```bash
# works without adding sources
sudo apt-get update
sudo apt-get install postgresql-10 postgresql-contrib libpq-dev
psql --version                      # psql (PostgreSQL) 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)
```

### setup Postgres user

<https://github.com/equivalent/scrapbook2/blob/master/postgresql.md>

```sh
# bash
sudo -u postgres psql 
```

```sql
# inside psql

CREATE USER myuser WITH PASSWORD 'myPassword';

# if you want him to be superuser
ALTER USER myuser WITH SUPERUSER;

# if you just want him to be able to create DB
ALTER USER myuser WITH CREATEDB;
```


be sure to set credentials in `config/database.yml` inside your Rails
project and now you can run `rake db:create` or `rake db:migrate`



## Install Redis


```bash
sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt-get update
sudo apt-get install redis-server
redis-server --version     # Redis server v=5.0.3 sha=00000000:0 malloc=jemalloc-5.1.0 bits=64 build=45d60903d31a0894
```

## Install MongoDB

Mongod v  v3.6.3


```bash
# works without adding sources
sudo apt-get update
sudo apt install mongodb
sudo systemctl start mongodb
```

If you want Mongo DB v 4 check <https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/>

## Install Elasticsearch

<https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-18-04>

```bash
sudo apt-get update

# install java
sudo apt-get install default-jre  default-jdk
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt update
sudo apt install elasticsearch

sudo systemctl status elasticsearch.service  # status
sudo systemctl start elasticsearch.service   # start server
sudo systemctl stop elasticsearch.service    # stop server

curl -X GET "localhost:9200"
```

## Docker


Main ref:

* <https://tecadmin.net/install-docker-on-ubuntu/>


```bash
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce

# add your user to docker user group (so you don't have to sudo all the time)
sudo groupadd docker
sudo usermod -aG docker $USER
# ...now log out and log back in
```

other ref:

* <https://docs.docker.com/install/linux/docker-ee/ubuntu/> 

## Docker compose

* <https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04>
* <https://github.com/docker/compose/releases/tag/1.23.2>

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version    # docker-compose version 1.23.2, build 1110ad01
```


## Imagemagic

> if you need image processing inside your Rails app with gems like
> [Carrierwave](https://github.com/carrierwaveuploader/carrierwave),
> [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html) or
> [Dragonfly](https://github.com/markevans/dragonfly)


```
sudo apt-get update
sudo apt-get install  imagemagick libmagickcore-dev libxslt-dev libmagickwand-dev
```


## Common Rails related errors:

#### error1

<https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers>

```
FATAL: Listen error: unable to monitor directories for changes.
Visit https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers for info on how to fix this.
```

solution

```bash
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

#### error2










> Ok that's it end of article. Down bellow is just some additional  software you may need (or not)


## DevOps tools

#### Heroku Toolbelt

<https://devcenter.heroku.com/articles/heroku-cli>

```bash
sudo snap install --classic heroku
```

#### AWS CLI

```bash
sudo apt update
sudo apt install awscli
```

#### AWS ElasticBenstalk CLI

<https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html>

```bash
sudo apt install python-pip
pip install awsebcli --upgrade --user
```

add this to your `.bash.rb`

```bash
export PATH=~/.local/bin:$PATH
```

#### Azure CLI

<https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest>

```bash
sudo apt-get install apt-transport-https lsb-release software-properties-common dirmngr -y
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv --keyserver packages.microsoft.com  --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
sudo apt-get update
sudo apt-get install azure-cli
```

#### Ansible

```bash
sudo apt-get update
sudo apt install ansible
```

> note this install ansible-vault as well


## My personal favorite utilities

```
# vim
sudo apt install -y  vim vim-gnome

# 7 zip full for encrypting file archives
sudo apt install p7zip-full
```

#### Janus Vim

Janus Vim is powerful extension of Vim to give it IDE like experienc

<https://github.com/carlhuda/janus>

```bash
curl -L https://bit.ly/janus-bootstrap | bash
```


#### Set up SSH server (Optional)

I have a history of destroying my laptops in accidents, so often I have
two laptops that I keep up to date with in case I damage one. In order
to do that I have SSH server on both of them so I can connect from other
to it and do updates as it it was a server when needed.

So this is only optional if you need SSH server on your laptop. If you
don't then don't do this

* <https://help.ubuntu.com/lts/serverguide/openssh-server.html.en>


Given you are configuring SSH server on Laptop1:

```bash
# run on Laptop1:

sudo apt install openssh-server
sudo vim  /etc/ssh/sshd_config       # not the simmilary named /etc/ssh/ssh_config
```

and make sure values are set to :

```
PubkeyAuthentication yes
PasswordAuthentication no
```


Copy content of public key of the Laptop2 `~/.ssh/id_rsa.pub`  to
`~/.ssh/authorized_keys` of the Laptop1



then run this on Laptop1:

```bash
sudo systemctl restart sshd.service
```

now try to ssh from Laptop2 to Laptop1 


## Discussion


