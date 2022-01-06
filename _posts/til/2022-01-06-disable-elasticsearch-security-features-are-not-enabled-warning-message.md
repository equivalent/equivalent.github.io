---
layout: til_post
title:  "disable ElasticSearch  security features are not enabled warning message"
categories: til
disq_id: til-92
---

Given I'm using Ruby on Rails and ElasticSearch gem in localhost
When any ElasticSearch update happens a warning message is logged:


```
warning: 299 Elasticsearch-7.16.2-2b937c44140b6559905130a8650c64dbd0879cfb "Elasticsearch built-in security features are not enabled. Without authentication, your cluster could be accessible to anyone. See https://www.elastic.co/guide/en/elasticsearch/reference/7.16/security-minimal-setup.html to enable security."
```

To silence  this add this line:


```
xpack.security.enabled: false
```

...to `elasticsearch.yml`


**WARNING be sure this is only in your development machine NEVER IN PRODUCTION !!**


e.g in OSx macbook this config file may be in:

```
/opt/homebrew/Cellar/elasticsearch-full/7.16.2/libexec/config/elasticsearch.yml
```

related notes:

* <https://blog.eq8.eu/til/change-elasticsearch-memory-usage-on-osx-macbook-homebrew.html>
* <https://blog.eq8.eu/til/publicly-accessible-elasticsearch-7x.html>
* <https://blog.eq8.eu/til/change-memory-size-for-elasticsearch-jvm-heap.html>
