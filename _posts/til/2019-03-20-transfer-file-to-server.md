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
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 25 ; echo ''
```

Copy that and use it in next step

```bash
gpg -c /tmp/my-file.csv
# Enter password
```

encrypted `/tmp/my-file.csv.gpg` is create

#### step2: transfer from laptop to cloud

transfer your encrypted file to cloud solution, for example
with [AWS s3 CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html)
or with Dropbox

> note: don't transfer the non encrytped file `/tmp/my-file.csv`!

##### AWS

* `aws s3 cp /tmp/my-file.csv s3://my-company-bucket-for-transactions/`
* `aws s3 sync /tmp/multiple-files/ s3://my-company-bucket-for-transactions/multiple-files/`

real life example:

```bash
aws s3 sync /tmp/export/ s3://my-company-bucket-for-transactions/export-2019-04-17
aws s3 ls s3://my-company-bucket-for-transactions/export-2019-04-17/

# now generate urls for download
aws s3 presign s3://my-company-bucket-for-transactions/export-2019-04-17/my-file.csv.gpg
# => https://my-company-bucket-for-transactions/export-2019-04-17/my-file.csv.gpg?AWSAccessKeyId=xxxxxxxxxxxxxxxxxxxx&Expires=1555585422&Signature=xxxxxxxxxxxxxxxxxxxxxxxxxxx%3D

```

> default expire time of [presign](https://docs.aws.amazon.com/cli/latest/reference/s3/presign.html) is 3600 sec. If you need more `--expires-in 999999`

##### Dropbox

```bash
cp /tmp/my-file.csv.gpg ~/Dropbox/my-company/
```
then generate a link in web interface


#### step3: transfer from cloud to server

on the web-console inside server/docker-container

```bash
cd /tmp/
wget https://my-cloud-solution.com/file?uniqtockennnnnnnnnnn
```
AWS

```bash
wget 'https://my-company-bucket-for-transactions.s3.amazonaws.com/export-2019-04-17/my-file.csv.gpg?AWSAccessKeyId=AKIAJNAHAMBRAGLAZCUQ&Expires=1555585422&Signature=RB1hk0gQUaVurAP6NKuaha4MlXI%3D'
```

> note with AWS presign url make sure you place the url into apostrophe
> `''` otherwise wget (or curl) will give you 403


#### step 4: delete file on cloud

Now that the encrypted file was trasfered **delete the file from cloud**!

> Note: don't hold files on cloud for too long. Delete them ASAP

> Note: If you use Dropbox make sure you go to Web interface and after
> deleting the file you go to "deleted files tab" and "delete the file
> permanently"

AWS

```bash
aws s3 rm s3://my-company-bucket-for-transactions/export-2019-04-17/my-file.csv.gpg

# or folder delete

aws s3 rm s3://my-company-bucket-for-transactions/export-2019-04-17 --recursive
```

#### step 5: Decrypt file on server with GPG


on the web-console inside server/docker-container

```bash
gpg /tmp/my-file.csv.gpg
# specify a password
```


## Simmilar problems:

#### Copy output & paste clipboard with `xclip`

This is quite a lazy but really effective way for 95% of cases wher you
need to copy some output **from server to your laptop**

> works on Ubuntu not sure about OsX

You need `xclip` command

```bash
sudo apt install xclip
```

1.  ssh / connect to bash of server.
2. Output some results to console (e.g `echo /tmp/myfile.csv`)
3. Just copy the console output (select and `SHIFT+CTRL+c`)
4. In other terminal (you laptop) type `xclip -o /tmp/mylocalcopy.csv`

Chances are you will also pase some clipboard junk so open the file and remove stuff you don't need

Now reason why you don't want to use just paste (e.g. with `ctrl+shift+v` in Vim is that it is time expensive

#### Send files from server

<https://blog.eq8.eu/til/send-files-of-server.html>


## sources

* <https://www.techrepublic.com/article/how-to-easily-encryptdecrypt-a-file-in-linux-with-gpg/>

## Related articles

* [Exporting and Importing large amount of data in Rails](https://blog.eq8.eu/til/exporting-importing-migrating-large-amount-of-data-in-ruby-on-rails.html)
