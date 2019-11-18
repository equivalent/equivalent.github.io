---
layout: til_post
title:  "Create AWS S3 bucket as a static website with AWS CLI"
categories: til
disq_id: til-72
---

In this TIL note I'll create static website hosted on AWS S3 bucket
using only AWS CLI.

We will create dummy static website on bucket called `happy-bunny`


## Create bucket

```bash
# create s3 bucket via AWS CLI
aws s3api create-bucket --bucket happy-bunny --region eu-west-1  --create-bucket-configuration LocationConstraint=eu-west-1

# ..or with profile option
aws s3api create-bucket --bucket happy-bunny --region eu-west-1  --create-bucket-configuration LocationConstraint=eu-west-1 --profile equivalent

```

* ` --profile nameofprofil` is only necesarry if you have multiple AWS accounts on your laptop (E.g work one is `default` and personal is `equivalent`)
* to understand why the LocationConstraint read [here](https://github.com/aws/aws-cli/issues/2603)


## Set bucket public policy


create a file `/tmp/bucket_policy.json` with this content:

```JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::happy-bunny/*"
        }
    ]
}
```

and run


```bash
aws s3api put-bucket-policy --bucket happy-bunny --policy file:///tmp/bucket_policy.json

# ..or with profile option
aws s3api put-bucket-policy --bucket happy-bunny --policy file:///tmp/bucket_policy.json --profile equivalent
```


## Now to upload my files


```bash
cd ~/my_folder_with_static_website

aws s3 sync ./ s3://happy-bunny/

# ..or with profile option
aws s3 sync ./ s3://happy-bunny/ --profile=equivalent

# upload: ./error.html to s3://happy-bunny/error.html
# upload: ./robots.txt to s3://happy-bunny/robots.txt
# upload: ./index.html to s3://happy-bunny/index.html
# upload: ./image.png to s3://happy-bunny/image.png
```

> static dummy website source:  <https://github.com/equivalent/happy-bunny-static-page>

## Tell AWS this should be website

```bash
aws s3 website s3://happy-bunny/ --index-document index.html --error-document error.html


# ..or with profile option
aws s3 website s3://happy-bunny/ --index-document index.html --error-document error.html  --profile equivalent
```

Notes:

* `s3://my-bucket/index.html` will be '/'
* `s3://my-bucket/error.html` will show on 404



Now you S3 bucket is public, set as a website and ready to go

Website will be:

`<bucket-name>.s3-website.<AWS-region>.amazonaws.com`

<http://happy-bunny.s3-website-eu-west-1.amazonaws.com>


## Script

Everything together in one script

```
echo '
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::happy-bunny/*"
        }
    ]
}
' > /tmp/bucket_policy.json

aws s3api create-bucket --bucket happy-bunny --region eu-west-1  --create-bucket-configuration LocationConstraint=eu-west-1 --profile equivalent
aws s3api put-bucket-policy --bucket happy-bunny --policy file:///tmp/bucket_policy.json --profile equivalent
aws s3 sync /home/t/git/equivalent/happy-bunny s3://happy-bunny/  --profile equivalent
aws s3 website s3://happy-bunny/ --index-document index.html --error-document error.html --profile equivalent
```


## Sources:

* <https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html>
* <https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html>
* <https://docs.aws.amazon.com/cli/latest/reference/s3/website.html>
* <https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html>

## Debugging

```
aws s3api   get-bucket-policy --bucket happy-bunny --profile equivalent
aws s3api   get-bucket-website --bucket happy-bunny --profile equivalent
```

#### AWS account may have global "block public access"

If the AWS S3 bucket owner's account has a [block public access setting applied](https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html#access-control-block-public-access-options) (which most accounts do by default) you may need to do some extra work in aws console:

* <https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html>
* <https://aws.amazon.com/premiumsupport/knowledge-center/read-access-objects-s3-bucket/>

My account also has this protection and the steps above worked. I'm just
putting it here in case anyone needs it.

#### CORS

* <https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html>

## Discussion

* <https://www.reddit.com/r/aws/comments/dy53hi/create_aws_s3_bucket_as_a_static_website_with_aws/>
* <https://www.reddit.com/r/programming/comments/dy54m8/create_aws_s3_bucket_as_a_static_website_with_aws/>
