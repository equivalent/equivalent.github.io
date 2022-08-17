---
layout: til_post
title:  "Elasticsearch 7 under Ubuntu - protect with basic password"
categories: til
disq_id: til-97
---

Set up simple password for ElasticSearch `7.17.5` localhost running under Ubuntu 20.04 from standard atp-get instalation ([example](https://blog.eq8.eu/article/set-up-ubuntu-1804-for-rails-developer-2019.html))

` sudo vim /etc/elasticsearch/elasticsearch.yml`

```yaml
# .....
# xpack.security.enabled: false  # make sure this is commented


discovery.type: single-node
xpack.security.enabled: true

```

```bash
sudo service elasticsearch stop 
sudo service elasticsearch status  
sudo service elasticsearch start  
sudo service elasticsearch status  
```

to set up password:

```bash
$ sudo  /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
```

Let say I hoose a pasword `xxmypaswdxx` :

test 

```bash
$  curl  -XGET localhost:9200

{"error":{"root_cause":[{"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}}],"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":"Basic realm=\"security\" charset=\"UTF-8\""}},"status":401




$  curl --user elastic:xxmypaswdxx -XGET localhost:9200

{
  "name" : "xxxxxxxx",
  "cluster_name" : "xxxxxxxx",
  "cluster_uuid" : "FWhvJOvmTCmp_Nevybmb2g",
  "version" : {
    "number" : "7.17.5",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "8d61b4f7ddf931f219e3745f295ed2bbc50c8e84",
    "build_date" : "2022-06-23T21:57:28.736740635Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

you can also `base64(username:pssword)` eg and pass it as header. E.g.: `base64(elastic:xxmypaswdxx) = "ZWxhc3RpYzp4eG15cGFzd2R4eA=="`

```bash
$ curl -H 'Authorization: Basic ZWxhc3RpYzp4eG15cGFzd2R4eA==' -XGET localhost:9200

{
  "name" : "xxxxxxxx",
  ...
}
```


```bash
$  curl  -XGET http://elastic:xxmypaswdxx@localhost:9200

{
  "name" : "xxxxxxxx",
  ...
}

```

### Ruby on Rails 

Most imortant for [Ruby/Rails ElasticSearch Client gem](https://github.com/elastic/elasticsearch-rails) you can pass it as a host, that means in Rails you can:

```ruby
# config/initializers/elasticsearch.rb
  client = Elasticsearch::Client.new(url: ENV.fetch('ELASTICSEARCH_HOST') )
```

make sure your `ENV['ELASTICSEARCH_HOST']="http://elastic:xxmypaswdxx@localhost:9200"`

### sources

* https://www.elastic.co/guide/en/elasticsearch/reference/7.17/security-minimal-setup.html
* https://www.elastic.co/guide/en/elasticsearch/reference/current/http-clients.html

### discusion