---
layout: til_post
title:  "Add Goddady ssl certificate to AWS Load Balancer"
categories: til
disq_id: til-88
---

Assuming you've already generated the `csr` files and private key without
password and you already have SSL certificate issued by GoDaddy

In GoDaddy go to `https://certs.godaddy.com/` in `Certs` pic certificate
and download the certificate for `Other` Server type. This will download
a zip file containing files: `xxxxxxxxxxxxxxxx.crt  xxxxxxxxxxxxxxxx.pem  gd_bundle-g2-g1.crt`

> note if your cert is close to expire  make sure you renew the
> certificate before downloading so that you have a longer period. If
> you are couple of days before expire don't worry you will gave year +
> those extra days on your new cert.


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

![AWS interface](/assets/2021/2021-04-13-aws-cert.png)

Click Import

All should work. Now select this cert for your https listener and all
should be fine


> note: if you want to use self-signed cert you don't need to specify chain


Sources:

* [godady: how to install cert on ELB](https://uk.godaddy.com/help/manually-install-an-ssl-certificate-on-my-aws-server-32075)
* [Certificate Chain with AWS ELB & GoDaddy Certs](https://serverfault.com/a/676228/218934)
* [How to self sign cert](https://github.com/equivalent/scrapbook2/blob/master/nginx.md#nginx-with-multiple-self-signed-certificates-for-same-ip)



