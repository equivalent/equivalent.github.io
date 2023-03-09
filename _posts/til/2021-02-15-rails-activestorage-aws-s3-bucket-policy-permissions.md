---
layout: til_post
title:  "Rails ActiveStorage AWS S3 bucket policy permissions"
categories: til
disq_id: til-86
---



Steps:


create a AWS s3 bucket and then create a new AWS IAM user:

1. create new user in AWS IAM (copy access_key and sectet and store them
to Rails credentials)
2. on "Set Permission" step click on "Attach existing policies directly"
3. click on "create policy" button
4. new window will popup where you paste the JSON policy from section "AWS Policy" bellow. Name it what you want
5. on "Set Permission" select the newly created policy (you many need to
   reload the page so it appears)


> Best practices for AWS are that for every Rails app enviroment you should have own user and own bucket.
> That means for production create s3 bucket `my-project-prod` and IAM user
> `my-project-prod` and for staging s3 bucket `my-project-stg` and IAM user
> `my-project-stg`. Same for develop if you are planing to use S3 there

## AWS Policy

from [ActiveStorage S3
guide](https://kylekeesling.dev/posts/2020/01/activestorage-s3-permissions)

>  The core features of Active Storage require the following permissions: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject`, and `s3:DeleteObject.` If you have additional upload options configured such as setting ACLs then additional permissions may be required.


```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
      ],
      "Resource": [
          "arn:aws:s3:::REPLACE_WITH_BUCKET_NAME/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": [
        "arn:aws:s3:::REPLACE_WITH_BUCKET_NAME"
      ]
    }
  ]
}
```

Sources

* <https://edgeguides.rubyonrails.org/active_storage_overview.html#s3-service-amazon-s3-and-s3-compatible-apis>

* <https://kylekeesling.dev/posts/2020/01/activestorage-s3-permissions>



### Cross-origin resource sharing (CORS)

If you want to use [Direct upload](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads)
you need to configure the CORS on AWS S3 bucket


In AWS go to S3 > click on bucket >  "Permissions" tab > down at the bottom "Cross-origin resource sharing (CORS) section"  > edit




```
[
    {
        "AllowedHeaders": [
            "Authorization"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    },
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "PUT"
        ],
        "AllowedOrigins": [
            "https://www.my-website.com"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```


> note: You want "Cross-origin resource sharing (CORS)" not the  "Bucket policy"
> which is under same "Permissions" tab


> note2: You DON'T need to enable access in the "Block public access (bucket settings)". That means Block all public access can stay set to
> "On" and direct upload will still work. That setting is confusingly
> for something else

sources: 

* <https://docs.aws.amazon.com/AmazonS3/latest/userguide/cors.html>
* <https://docs.sevenbridges.com/docs/enabling-cross-origin-resource-sharing-cors>
* <https://edgeguides.rubyonrails.org/active_storage_overview.html#cross-origin-resource-sharing-cors-configuration>
