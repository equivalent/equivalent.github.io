---
layout: til_post
title:  "Send files from Server"
categories: til
disq_id: til-23
redirect_from:
  - "/tils/23"
  - "/tils/23-send-files-from-server"
---


Sometimes you are on a server where you generate export file. It's easy
to just `scp` the file from the server to your local machine.

```bash
scp user@server.com:/tmp/myfile.csv  /tmp/local_folder/
```

But some times you are dealing
with a situation where you can `ssh` but you cannot `scp`
(AWS Elastic Beanstalk is a good example)

If the file don't contain private data (passwords, emails) what you can do is email
the file on your work email.

Steps:

* install `mutt` mail command (simple mailng inteface supporting
attachment files)
* compress your file / folder
* send file attachment with  with `mutt`

`mutt` syntax:

```bash
echo "mail body" | mutt -a file -s "Subject" -- my@email.com
```

example:


```bash
## install mutt command:
#
# sudo apt-get install mutt
# sudo yum install mutt

# Given we have generated `views.csv` file
gzip views.csv
echo "mail body" | mutt -a views.csv.gz -s "MyApp view stat files" -- tomas@eeeeeeeeeeeeq.ee


# Given we mupltiple files in directory `views/`
tar -zcvf views.tar.gz views/
du -sh views.tar.gz

echo "mail body" | mutt -a views.tar.gz -s "MyApp view stat files" -- tomas@eeeeeeeeeeeeq.ee
```


**Warning** I do recommend to encrypt the file before sending 

e.g.:

```bash

zip -P password file.zip file

# ...or:

zip -e file.zip file

# ...or:

gpg -o fileToTar.tgz.gpg --symmetric fileToTar.tgz

# to decrypt
gpg fileToTar.tgz.gpg
```

## Lazy solution - Copy outut paste clipboard with `xclip`

This is quite a lazy but really effective way for 95% of cases where you
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

## Transfer large files to server

<https://blog.eq8.eu/til/transfer-file-to-server.html>

#### Sources

* <https://github.com/equivalent/scrapbook2/blob/master/linux.md>
* <https://superuser.com/questions/370389/how-do-i-password-protect-a-tgz-file-with-tar-in-unix>
