---
layout: til_post
title:  "Custom domain / subdomain for website hosted on AWS S3"
categories: article
disq_id: 58
description:
  You can use AWS S3 bucket to host static websites. In this article
  I'll show you how you can set this up with custom subdomains / domains using AWS CLI

---


You can configure Amazon Web Services (AWS) [S3](https://aws.amazon.com/s3/) buckets to  host static websites (e.g. static HTML+CSS+JavaScript website or Single Page App (SPA) Frontend )

In this Article I'll show you how to set AWS S3 bucket:

1. AWS S3 bucket as a Subdomain website
2. AWS S3 bucket as a Custom Domain website
3. How to secure it with `https://`


The core principle is that you need to name your S3 bucket same way how
the domain / subdomain will be named.

So for example if you want `www.happy-bunny.xyz` you create AWS S3 bucket with
the name `www.happy-bunny.xyz`

If you want to have subdomain on existing domain e.g.
`happy-bunny.eq8.eu` then you create AWS S3 bucket `happy-bunny.eq8.eu`


## AWS S3 as a Subdomain website

We will create static website on `happy-bunny.eq8.eu`

In my TIL note [website on S3 with AWS CLI](https://blog.eq8.eu/til/create-aws-s3-bucket-as-static-website-with-cli.html) I showed you how to set up AWS S3 Bucket using [AWS CLI](https://aws.amazon.com/cli/).
So lets use the "script" from that article:

> If you want to do it from Web interface check this [AWS docs - static website on S3 webinterface](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)

Create a new file in: `/tmp/create_bucket.sh`

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

* be sure you replace `/tmp/SOURCE_FOLDER` with where your keep your files on your computer
* be sure you replace `s3://happy-bunny.eq8.eu/` with the name of your bucket

And run the file with `bash /tmp/create_bucket.sh`

> If any errors pls check [this](2019-11-18-create-aws-s3-bucket-as-static-website-with-cli.md) TIL note (debugging section)



Once successful we have it hosted here: <http://happy-bunny.eq8.eu.s3-website-eu-west-1.amazonaws.com/>

Now we will create `CNAME`  DNS record on domain `eq8.eu`  to point `happy-bunny.eq8.eu` to `happy-bunny.eq8.eu.s3-website-eu-west-1.amazonaws.com`


![add DNS record for subdomain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-add-subdomain-dns-record.png)

> On official [AWS docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html#root-domain-walkthrough-add-arecord-to-hostedzone) has different
> way where you host your DNS records in [AWS Route 53](https://console.aws.amazon.com/route53/) and point A Records to buckets. I don't like this solution as I like to use
>  [Cloudflare](https://cloudflare.com/) for free `https://`. More on that in section bellow.


**And it works !!! <https://happy-bunny.eq8.eu/>**


![happy-bunny.eq8.eu subdomain works](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-subdomain-works.png)

That's all



## AWS S3 bucket as a Custom Domain website

We will create static website on `www.happy-bunny.xyz`


In my TIL note [website on S3 with AWS CLI](https://blog.eq8.eu/til/create-aws-s3-bucket-as-static-website-with-cli.html) I showed you how to set up AWS S3 Bucket using [AWS CLI](https://aws.amazon.com/cli/)
So lets use the "script" from that article:

> If you want to do it from Web interface check this [AWS docs - static website on S3 webinterface](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)


Create a new file in: `/tmp/create_bucket.sh`

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
            "Resource": "arn:aws:s3:::www.happy-bunny.xyz/*"
        }
    ]
}' > /tmp/bucket_policy.json

aws s3api create-bucket --bucket www.happy-bunny.xyz --region eu-west-1  --create-bucket-configuration LocationConstraint=eu-west-1 --profile equivalent \
  && aws s3api put-bucket-policy --bucket www.happy-bunny.xyz --policy file:///tmp/bucket_policy.json --profile equivalent \
  && aws s3 sync /tmp/SOURCE_FOLDER s3://www.happy-bunny.xyz/  --profile equivalent \
  && aws s3 website s3://www.happy-bunny.xyz/ --index-document index.html --error-document error.html --profile equivalent
```


* be sure you replace `/tmp/SOURCE_FOLDER` with where your keep your files on your computer
* be sure you replace `s3://www.happy-bunny.xyz/` with the name of your bucket


And run the file with `bash /tmp/create_bucket.sh`

> If any errors pls check [this](2019-11-18-create-aws-s3-bucket-as-static-website-with-cli.md) TIL note (debugging section)


Once successful we have it hosted here: <http://www.happy-bunny.xyz.s3-website-eu-west-1.amazonaws.com/>

In our `happy-bunny.xyz` domain we will create DNS record `CNAME`  to point `www` to `www.happy-bunny.xyz.eu.s3-website-eu-west-1.amazonaws.com`

![add DNS record for domain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-websites-domain-works.png)

Website works now on: <http://www.happy-bunny.xyz/>

> NOTE: For purpose of this article I've registered domain `happy-bunny.xyz` it cost me `$1.99` but renewal is `$9` so I'll not be renewing this domain next year.
> So if you reading this in 2020 chances are that there is something else hosted on that domain.

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-buy-domain.png)


#### Naked domain

So great our `www` subdomain works. But what about the "Naked domain" `happy-bunny.xyz` (without the `www` in front) ?

I would recommend to just use [wwwizer](http://wwwizer.com/naked-domain-redirect). All you need to do is point your DNS root `A` record to `174.129.25.170` and when
someone loads `http://happy-bunny.xyz` he/she will get redirected to `http://www.happy-bunny.xyz`

![add DNS record for domain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-domain-dns.png)

> On official [AWS docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html#root-domain-walkthrough-add-arecord-to-hostedzone) has different
> way where you host your DNS records in [AWS Route 53](https://console.aws.amazon.com/route53/) and point A Records to buckets (I don't like this solution as I like to use
>  [Cloudflare](https://cloudflare.com/) for free `https://`. More on that in section bellow)
> Therefore you can create bucket `happy-bunny.xyz` to host the static pages.  It's up to you if you want to go this way.


## Cloudflare for free https and caching

In order to get https for free on your website I would recommend to
create [Cloudflare](https://cloudflare.com/) account and transfer your
DNS nameserver records (NS records) for your domain to Cloudflare

> No worries this is NOT "transfer domain". You will only point DNS
> name servers (NS) to different location

![add DNS record for domain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-website-cloudflare.png)

Once in Cloudflare go to "SSL/TLS" section and choose "flexible" for
your domain.

This way you will end up with:

`http://www.happy-bunny.xyz` and `https://www.happy-bunny.xyz`

You can go one step further and configure "Always Use HTTPS" (in `SSL/TLS > Edge Certificates > Always Use HTTPS > ON`) this way when someone goes to 
`http://www.happy-bunny.xyz` he/she will get redirected to `https://www.happy-bunny.xyz`


![add DNS record for domain](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/aws-s3-static-websiteshttps.png)

An additional benefit of Cloudflare is that it will provide caching for your static files on DNS level.

Because you pay for AWS S3 bucket depending how much data you store but
also "how much data is transfered" you may get slightly bigger bill if
large files are requested too often (e.g. someone created script pulling
large image from your website in infinite loop)


If you configure Cloudflare the right way you can tell it to cache all
the file and you will avoid this problem. It's a static website anyway.

Just be sure to be careful how you set it up if you need to do frequent
deployments (think about how will the cache get invalidated)

> If you want to transfer Route53 to Cloudflare check [this article](https://blog.eq8.eu/article/aws-route-53-cloudflare.html)

## Other tips

**Ruby** dudes [Middleman](https://middlemanapp.com/) or [Jekyll](https://jekyllrb.com/)  are Static website frameworks. What you can do is compile project to static Websites and upload the compiled content to s3 website bucket

```bash
middleman build
aws s3 sync ./build s3://www.name-of-my-website.eu
```

I've created several website for friends and familly this way

* <http://www.zdenka.eu/>
* <http://www.shortie.sk/>

> But if you use Jekyll you can  host static websites on [Github Pages](https://pages.github.com/). e.g. [elkar.sk](https://elkar.sk/) ([source](https://github.com/elkar-slovakia/elkar-slovakia.github.io))


**JavaScript** dudes you can build SPA websites and host them on S3 buckets

Then backend can be built with AWS API Gateway and AWS lambda Functions (you pay for Lambda functions only if they are triggered) and AWS Dynamo DB as DB (you pay only for rows in DB) so you end up with "Serverless" platform
This way you can build application FE + BE + DB that can cost you 0.0x per month if not used often (but if you have web app used as often as regular server prices will be comparable to webhosting)

Really interesting book on this topic is <https://pragprog.com/book/brapps/serverless-single-page-apps>

> I have a talk on this topic: <https://youtu.be/fn17nojYa-I?t=1359>

## Sources

* [AWS docs - Setting Up a Static Website Using a Custom Domain](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html)
* <https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html>

## Discussion

* <https://www.reddit.com/r/aws/comments/dz3eg0/custom_domain_subdomain_for_website_hosted_on_aws/>
* <https://www.reddit.com/r/programming/comments/dz3e7b/custom_domain_subdomain_for_website_hosted_on_aws/>
* <https://www.reddit.com/r/javascript/comments/dz3q3y/static_website_hosted_on_aws_s3_good_for_cheap/>
* <https://www.reddit.com/r/ruby/comments/dz3otg/custom_domain_subdomain_for_website_hosted_on_aws/>
