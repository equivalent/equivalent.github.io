---
layout: til_post
title:  "Add Goddady ssl certificate to AWS Load Balancer"
categories: til
disq_id: til-88
---

Assuming you already generated the `csr` files and private key without
password and you already have SSL certificate issued by GoDaddy

In GoDaddy go to `https://certs.godaddy.com/` in `Certs` pic certificate
and download the certificate for `Other` Server type. This will download
a zip file containing files: `xxxxxxxxxxxxxxxx.crt  xxxxxxxxxxxxxxxx.pem  gd_bundle-g2-g1.crt`


In AWS: go to `EC2` > `Load Balancers` (left menu) > pic a load balancer;
Then select `Listener` tab, and either add https port or click `View/edit certificates` on existing https setup.
You will end up in `Certificates` interface. Her you click the big `+`
button and in middle of sreen you should see `Import certificate`
option. Here you will these options:

* **Ipmort to**  choose  `IAM`
* **Certificate name**   whatever you want
* **Certificate private key (PEM encoded)** : paste value of your private key without a password (the key you use to sign your csr in first place)
* **Certificate body (PEM encoded)** paste value of `xxxxxxxxxxxxxxxx.crt` from the downloaded Godaddy zip file
* **Certificate chain (PEM encoded)** paste value of `gd_bundle-g2-g1.crt` from the downloaded Godaddy zip file

Click Import

all should work. Now select this cert for your https listener and all
should be fine


> note: in the past you shold sign the cert [like disribed here](https://github.com/equivalent/scrapbook2/blob/master/nginx.md#nginx-with-multiple-self-signed-certificates-for-same-ip) that is no longer reqired


Sources: 

* [godady: how to install cert on ELB](https://uk.godaddy.com/help/manually-install-an-ssl-certificate-on-my-aws-server-32075)
* [Certificate Chain with AWS ELB & GoDaddy Certs](https://serverfault.com/a/676228/218934)



