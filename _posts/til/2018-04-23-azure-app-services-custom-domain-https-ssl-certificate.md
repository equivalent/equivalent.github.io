---
layout: til_post
title:  "Azure App Services - custom domain https ssl certificate"
categories: til
disq_id: til-99
---


```
Given I've generated SSL certificates on Goddady
And I've downloaded the PEM certificate: root-chain.crt and the domain.crt (e.g. By chosing other server)
Then  I want to add it to Azure App Services load balancer
```

Problem is Azure supports only `pfx` certificates not `pem` certificates
so what you need to do is:

1. join the root-chaing cert (PEM) and domain cert (PEM)

```
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
```

2. Generate `pfx` cert

> This article was written 2018-04-25 and Azure don't support PEM certs those days (this may change in the future)
> you need to covert the PEM certifictae to  PFX format

```
openssl pkcs12 -export -out myserver.pfx -inkey private.key -in domain-and-root-cert-bundle.crt
```

You will be asked for a password. Password will be needed in the Azure
portal interface

3. Assign domain for your App service

this is crucial. If you don't do this you will be able to "upload"
certificate but not able to assign that certificate to App Service


Go to `App Services > "your application" > Custom Domains > Add Hostname > "your-url-for-which-you-have-sslcert.com"`

4. Upload & assign certificate to App Service

Go to `App Services > "your application" > SSL Settings > In "Certificates" section "upload certificate" > type "private" PFX for the domain `

you need to wait a while while that cert is processed and after that it
will appear in (same page)


`App Services > "your application" > SSL Settings > In "Private Credentials" section"`

When that happens go to (same page)

`App Services > "your application" > SSL Settings > In "SSL binding" section > Add Binding`

and now choose `"your-url-for-which-you-have-sslcert.com"` from
dropdown and certificate for it "SNI SSL" and click button "Add Binding"


Sources:

* <https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-ssl>
* <https://www.sslshopper.com/ssl-converter.html>
* <https://stackoverflow.com/questions/808669/convert-a-cert-pem-certificate-to-a-pfx-certificate>

