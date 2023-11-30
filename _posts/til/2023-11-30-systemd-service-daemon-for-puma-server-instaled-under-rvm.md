---
layout: til_post
title:  "System.d service (daemon) for Puma server instaled under RVM (Rails)"
categories: til
disq_id: til-101
---


Systemd ignores any `PATH` settings = you need to use full path to rvm.
In order to use puma under RVM with systemd you need to create a wrapper for RVM:

```bash
cd /root/myapp
rvm current                                   # e.g.: ruby-3.2.2@myapp_2023

# create RVM wrapper
rvm alias create myapp ruby-3.2.2@myapp_2023  # rybyversion@gemsetname
```

Depending where is your RVM instaled (check with `which rvm`) this creates a wrapper in RVM folder. Mine is `/usr/share/rvm/wrappers/myapp` . This you  can refer in systemd service file. (RVM wrapper is something similar to  aias or symbolic link)

```
# /etc/systemd/system/myapp_puma.service

[Unit]
Description=Puma HTTP Server
After=network.target

# Uncomment for socket activation (see below)
# Requires=puma.socket

[Service]
Type=notify

WatchdogSec=10

# Preferably configure a non-privileged user
# User=

WorkingDirectory=/root/myapp_tw

# Explicitly define your ENV variables as they may be ignored
Environment=WEB_CONCURRENCY=3
Environment=RAILS_ENV=production

# Helpful for debugging socket activation, etc.
# Environment=PUMA_DEBUG=1

ExecStart=/usr/share/rvm/wrappers/myapp/bundle exec puma -C ./config/puma.rb

Restart=always

[Install]
WantedBy=multi-user.target
```

> note: I `ln -s ` my `master.key` to app `config/master.key` so I don't use `RAILS_MASTER_KER`

```bash
systemctl daemon-reload              #each  time you change the service file
systemctl start myapp_puma.service
systemctl status myapp_puma.service

# something goes wrong
journalctl -u myapp_puma -e -f
```

> Note: any time you change ruby version or gemset you need to recreate the RVM wrapper

source:
* <https://github.com/puma/puma/blob/master/docs/systemd.md>
* <https://rvm.io/deployment/init-d>

Rails 7.1, Ruby 3.2, Puma 6, RVM rvm 1.29.12, Ubuntu 22.04. Created 2023-11-30

keywords: init.d,  system.d, puma webserver, ruby on rails, rvm


