---
layout: til_post
title:  "Stimulus JS Cheat Sheet"
categories: til
disq_id: til-77
---

Rails 6 Stimulous JS Cheat Sheet


#### Controller names

file: `snake_case.js` identifier: `kebab-case`

> Always use dashes in `data-controller` values for multi-word controller identifiers. [source](https://github.com/stimulusjs/stimulus/blob/1522e4620120594e93cd1e4b0c9e2577ae94c530/INSTALLING.md#using-webpack)

`app/javascript/controllers/entries_search_controller.js` (or `app/javascript/controllers/entries-search-controller.js`)


```js
// app/javascript/controllers/entries_search_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  // ...
}
```

```html
<div data-controller="entries-search"></div>
```

```slim
div data-controller="entries-search"
```

#### Action names

`cammelCase`


```js
// app/javascript/controllers/entries_search_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  makeRequestNow() {
    alert("request was made (not really)");
  }
}
```


```html
<div data-action="click->entries-search#makeRequestNow"></div>


<div data-action="click->entries-search#makeRequestNow" class="chip hoverable"></div>
```

```slim
div data-action="click->entries-search#makeRequest"

.chip.hoverable data-action="click->entries-search#makeRequest"
```










### Sources

* [Stimulus case covention table](https://github.com/stimulusjs/stimulus/issues/70#issuecomment-359991756)
* alternative [Stimulous JS Cheat Sheet](https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e)
