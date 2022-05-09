---
layout: til_post
title:  "Use Importmaps without Rails"
categories: til
disq_id: til-96
---

![](https://images.unsplash.com/photo-1621839673705-6617adf9e890?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1332&q=80)

Rails 7 embraced the use of [Import maps](https://github.com/rails/importmap-rails) and they are awesome.

If you wonder how to use importmap in plain HTML here is an example:


```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Import maps without Rails - Local-time example</title>

    <script async src="https://unpkg.com/es-module-shims@1.2.0/dist/es-module-shims.js"></script>
    <script type="importmap-shim">
      {
        "imports": {
          "local-time": "https://ga.jspm.io/npm:local-time@2.1.0/app/assets/javascripts/local-time.js"
        }
      }
    </script>
    <script type="module-shim">
      import LocalTime from "local-time"
      LocalTime.start()
    </script>

    <style>
      time { color: #c11; font-size: 1.1em; }
    </style>
  </head>
  <body>
    <h1>Import maps without Rails - Local-time JS example</h1>

    <p>
      Last time I had chocolate was <time datetime="2022-05-08T23:00:00+02:00" data-local="time-ago">8th of May</time>
    </p>

  </body>
</html>
```

> to see the example in action check [this JS fiddle](https://jsfiddle.net/8oa9fjbs/)


Example uses importmap to loads <a href="https://www.npmjs.com/package/local-time">local-time js</a>
that converts `<time>` HTML elements from UTC to the browser's local time (<a href="https://github.com/basecamp/local_time">more info</a>).


### Other examples

Looking for Hotwire Stimulus examples ?
* Some can be found in [stimulus-autocomplete gem examples](https://github.com/afcapel/stimulus-autocomplete/tree/main/examples)


### Source

* Photo by Jackson So via [unsplash](https://unsplash.com/photos/_t-l5FFH8VA)
* <https://www.npmjs.com/package/local-time>
* <https://github.com/basecamp/local_time>
* <https://github.com/afcapel/stimulus-autocomplete/tree/main/examples>
* <https://github.com/rails/importmap-rails>

### Discussion
