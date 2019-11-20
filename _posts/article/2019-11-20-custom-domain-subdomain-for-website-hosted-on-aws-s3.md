---
layout: til_post
title:  "Custom domain / subdomain for website hosted on AWS S3"
categories: article
disq_id: 58
description:
  You can use AWS S3 bucket to host static websites. In this article
  I'll show you how you can set this up with custom subdomains / domains using AWS CLI

---


You can configure Amazon Web Services (AWS) [S3](https://aws.amazon.com/s3/) buckets to  host static websites (e.g. static HTML+CSS+JavaScript website or Single Page Apps (SPA) Frontend )

In this Article I'll show you how to set S3 bucket for custom domanin / subdomain.


The core principle is that you need to name yout S3 bucket same way how
the domain / subdomain will be named.

So for example if you want `www.happy-bunny.xyz` you create AWS S3 bucket with
the name `www.happy-bunny.xyz`

If you want to have subdomain on existing domain e.g.
`happy-bunny.eq8.eu` then you create AWS S3 bucket `happy-bunny.eq8.eu`


### Creating AWS S3 bucket website as Subdomain

We will create static website on `happy-bunny.eq8.eu`

In my TIL note [website on S3 with AWS CLI](https://blog.eq8.eu/til/create-aws-s3-bucket-as-static-website-with-cli.html) I showed you how to set up AWS S3 Bucket using [AWS CLI](https://aws.amazon.com/cli/).
So lets use the "script" from that article:

> If you want to do it from Web interface check this [AWS docs - static website on S3 webinterface](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)


```bash
#!/bin/bash
echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::happy-bunny.eq8.eu/*"
        }
    ]
}' > /tmp/bucket_policy.json

aws s3api create-bucket --bucket happy-bunny.eq8.eu --region eu-west-1  --create-bucket-configuration LocationConstraint=eu-west-1 \
  && aws s3api put-bucket-policy --bucket happy-bunny.eq8.eu --policy file:///tmp/bucket_policy.json \
  && aws s3 sync /tmp/SOURCE_FOLDER s3://happy-bunny.eq8.eu/  \
  && aws s3 website s3://happy-bunny.eq8.eu/ --index-document index.html --error-document error.html
```

Note:

* be sure you replace `/tmp/SOURCE_FOLDER` with where your keep your files on your computer
* be sure you reploace `s3://happy-bunny.eq8.eu/` with the name of your bucket
* for debugging pls check [this](2019-11-18-create-aws-s3-bucket-as-static-website-with-cli.md) TIL note (debugging section)

Once successfull we have it hosted: <http://happy-bunny.eq8.eu.s3-website-eu-west-1.amazonaws.com/>

Now we will create `CNAME`  DNS record on domain `eq8.eu`  to point `happy-bunny.eq8.eu` to `happy-bunny.eq8.eu.s3-website-eu-west-1.amazonaws.com`


![add DNS record for subdomain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-add-subdomain-dns-record.png)


And it works <https://happy-bunny.eq8.eu/>


![happy-bunny.eq8.eu subdomain works](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-subdomain-works.png)

> Reason why I have `https://` is because I have my DNS records on [Cloudflare](https://cloudflare.com/) more on that bellow



### Creating AWS S3 bucket website as a Custom Domain

We will create static website on `www.happy-bunny.xyz`

For purpouse of this article I've registered domain `happy-bunny.xyz` it cost me `$1.99` but renewal is `$9` so I'll not be renewing this domain next year.
So if you reading this in 2020 chances are that there is something else hosted on that domain.

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-buy-domain.png)


In my TIL note [website on S3 with AWS CLI](https://blog.eq8.eu/til/create-aws-s3-bucket-as-static-website-with-cli.html) I showed you how to set up AWS S3 Bucket using [AWS CLI](https://aws.amazon.com/cli/)
So lets use the "script" from that article:

> If you want to do it from Web interface check this [AWS docs - static website on S3 webinterface](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)




### Sources

* [AWS docs - Setting Up a Static Website Using a Custom Domain](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html)
* <https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html>
