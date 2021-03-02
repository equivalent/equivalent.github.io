---
layout: til_post
title:  "Publicly accessible Elasticsearch 7.x"
categories: til
disq_id: til-87
---

how to expose ElasticSearch on a VM globaly (public access)

or: How to access ElasticSearch 7.x installed on a VM from my laptop

> note this is a terrible idea! don't do this for production ES. This is
> only usefull for debugging or if you have strong firewall setup


Edit  file `/etc/elasticsearch/elasticsearch.yml` to values: 


```
network.host: 0.0.0.0
network.bind_host: 0.0.0.0
network.publish_host: 0.0.0.0


discovery.seed_hosts: ["0.0.0.0", "[::0]"]
```


and restart elasticsearch `sudo service elasticsearch stop`  + `... start`

source <https://stackoverflow.com/a/65718115/473040>

