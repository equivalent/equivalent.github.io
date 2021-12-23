---
layout: til_post
title:  "change Elasticsearch memory consumption on OSX (macbook, homebrew)"
categories: til
disq_id: til-91
---


I've installed Elasticsearch with homebrew on my OSX Macbook ([source](https://www.elastic.co/guide/en/elasticsearch/reference/current/brew.html))

```bash
brew tap elastic/tap
brew install elastic/tap/elasticsearch-full
```

> note you also need to install Java JDK [source](https://stackoverflow.com/questions/70455469/brew-install-elasticsearch-on-m1-macbook-results-in-bad-cpu-type-in-executable)


Now if I start elasticsearch it consumes 4GB - 8GB of Ram == not good

In order to change this I need to change value of JVM HEAP size for
ELasticsearch in `jvm.options` file

Now because homebrew  installed Elasticsearch `7.16` the path where my
ES conf files are located is:


```
/opt/homebrew/Cellar/elasticsearch-full/7.16.2/libexec/config/jvm.options
```

Now I need to add following lines to the file:

```
# ...
-Xms1g
-Xmx1g
# ...
```

This will use 1 GB of Ram


if I want even less I can do 


```
# ...
-Xms300m
-Xmx300m
# ...
```

to use 300 MB of memory


Remember to stop/start your ES service in order for this to take any
effect

```bash
brew services stop  elasticsearch-full
brew services start elasticsearch-full
```

If you googled this note and you are using Ubuntu check my older note: [change Ubuntu elasticsearch memory consumption](https://blog.eq8.eu/til/change-memory-size-for-elasticsearch-jvm-heap.html)

