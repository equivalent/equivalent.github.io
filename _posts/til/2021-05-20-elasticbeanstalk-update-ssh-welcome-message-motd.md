layout: til_post
---
title:  "AWS ElasticBeanstalk update ssh welcome message (motd)"
categories: til
disq_id: til-89
---


In order to update welcome message after `ssh` a.k.a message of the day (motd) we need to write our custom
motd script to the AWS ElasticBeanstalk (EB) EC2 instace `/etc/update-motd.d/20-custom-welcome-message`

in order to do that we can tell `.ebextensions` to write that file after
deployment

> If you need more info on what the f. in `.ebextensions`  check [this article](https://blog.eq8.eu/article/aws-elasticbeanstalk-hooks.html)


Inside  your project folder (where you execute `eb deploy` or `eb ssh`) create folder `.ebextensions` and crate a file
`.ebextensions/91_update_motd_welcome_message_after_ssh.config` with content

```yaml
files:
  "/tmp/20-custom-welcome-message":
    mode: "000755"
    owner: root
    group: root
    content: |
      cat << EOF
      THIS WILL BE YOUR WELCOME MESSAGE
      EOF

commands:
  80_tell_instance_to_regenerate_motd:
    command: mv /tmp/20-custom-welcome-message /etc/update-motd.d/20-custom-welcome-message

  99_tell_instance_to_regenerate_motd:
    command: /usr/sbin/update-motd
```


We create motd file to `/tmp/` folder and then copy it to `/etc/update-motd.d` where it's picked up. Reason why we don't write it directly to this folder is because
`.ebextensions` `files` will create `.bck` file with a backup of the
original file on server. This would result in two motd messages.


### Force motd regenerate

we are running following to regenerate motd files so that it's picked up
by instance without restart

```bash
sudo /usr/sbin/update-motd
```


if this don't work try


```
sudo run-parts /etc/update-motd.d/
```

> Based on [this article](http://mytechmembank.blogspot.com/2018/06/motd-on-aws-linux-instances.html#:~:text=To%20change%20the%20MOTD%20on,output%20of%20all%20the%20scripts)

### my custom welcome message

If interested here is  my setup is Ruby on Rails application running in Docker container.
I like to output quick copy-paste docker exec commands for ease of use.
The image name is `my-webserver-v3` or `my-webserver-v3` that's why the
`grep v3` part

```yaml
files:
  "/tmp/20-custom-welcome-message":
    mode: "000755"
    owner: root
    group: root
    content: |
      cat << EOF

      This EC2 instance is running Docker container with Ruby on Rails. To access the container:

          sudo docker ps
          sudo docker exec -it xxxxxxx bash
          sudo docker exec -it $( sudo docker ps | grep v3 | awk '{print $1;}' | tail -n 1) bash

      To execute Ruby on Rails console:

          sudo docker ps
          sudo docker exec -it xxxxxxx bin/rails c
          sudo docker exec -it $( sudo docker ps | grep v3 | awk '{print $1;}' | tail -n 1) bin/rails c
      test33

      EOF

commands:
  80_tell_instance_to_regenerate_motd:
    command: mv /tmp/20-custom-welcome-message /etc/update-motd.d/20-custom-welcome-message

  99_tell_instance_to_regenerate_motd:
    command: /usr/sbin/update-motd
```


### related & sources

* <http://mytechmembank.blogspot.com/2018/06/motd-on-aws-linux-instances.html#:~:text=To%20change%20the%20MOTD%20on,output%20of%20all%20the%20scripts>
* <https://blog.eq8.eu/article/aws-elasticbeanstalk-hooks.html>
* <https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/customize-containers-ec2.html#linux-files>



