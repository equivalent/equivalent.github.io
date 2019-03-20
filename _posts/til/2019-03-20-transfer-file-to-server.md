---
layout: til_post
title:  "Securely transfering files to server"
categories: til
disq_id: til-58
---


Many times developer needs to copy over database dump or some migration
csv file containing data to server. Easiest way is to just do `scp` but sometimes
you are not able to do that due to firewall restrictions, or because you
have only web-console availble, therefore  no real `ssh` connection
(e.g. Kubernetes dashboard)

## scp

So if you have direct `ssh` access to server easiest way is to do `scp`

```bash
scp /tmp/my-file.csv user@123.123.123.123:project/folder/

scp /tmp/my-file.csv user@123.123.123.123:/home/user/project/folder/

scp /tmp/my-file.csv user@123.123.123.123:/tmp

# multiple files
scp -r /tmp/folder-full-of-files user@123.123.123.123:/tmp/
```


## encrypt file, push to cloud, pull from cloud

When you don't have direct `ssh` access to the server, but you can start
connection with web-console for example.

#### step1: Encypt file with GPG


optional step - generate random string (like `q0nI2ReFF8PlUeQfWFZL`)

```bash
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''
```

Copy that and use it in next step

```bash
gpg -c /tmp/my-file.csv
# specify a password
```

encrypted `/tmp/my-file.csv.gpg` is create

#### step2: transfer from laptop to cloud

transfer your encrypted file to cloud solution, for example:

* [AWS s3 CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html)
  * `aws s3 cp /tmp/my-file.csv s3://my-company-bucket-for-transactions/`
  * `aws s3 sync /tmp/multiple-files/ s3://my-company-bucket-for-transactions/multiple-files/`
* dropbox
  * `cp /tmp/my-file.csv.gpg ~/Dropbox/my-company/`, then generate a link in web interface

> note: don't transfer the non encrytped file `/tmp/my-file.csv`!


#### step3: transfer from cloud to server

on the web-console inside server/docker-container

```bash
cd /tmp/
wget http://my-cloud-solution.com/file?uniqtockennnnnnnnnnn
```

#### step 4: delete file on cloud

Now that the encrypted file was trasfered **delete the file from cloud**!

> Note: don't hold files on cloud for too long. Delete them ASAP

> Note: If you use Dropbox make sure you go to Web interface and after
> deleting the file you go to "deleted files tab" and "delete the file
> permanently"

#### step 5: Decrypt file on server with GPG


on the web-console inside server/docker-container

```bash
gpg /tmp/my-file.csv.gpg
# specify a password
```





## sources
* https://www.techrepublic.com/article/how-to-easily-encryptdecrypt-a-file-in-linux-with-gpg/