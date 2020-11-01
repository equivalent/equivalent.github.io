---
layout: til_post
title:  "Stimulus JS Cheat Sheet"
categories: til
disq_id: til-77
---

Rails 6 Stimulous JS Cheat Sheet

Official docs [stimulusjs.org](https://stimulusjs.org/)


#### Controller names

file: `snake_case.js` identifier: `kebab-case`

> Always use dashes in `data-controller` values for multi-word controller identifiers. [source](https://github.com/stimulusjs/stimulus/blob/1522e4620120594e93cd1e4b0c9e2577ae94c530/INSTALLING.md#using-webpack)

`app/javascript/controllers/entries_search_controller.js` (or `entries-search-controller.js`)


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





## How to fetch data values

```js
// app/javascript/controllers/entries_search_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  giveMeSomeData(event) {
    // Access the Controller data
    console.log(this.data.get('categories-load-path'));
    // => /band_search


    // Access data on currently clicekd element
    console.log(event.currentTarget.dataset.favoriteBand);
    // => Parkway Drive


    // Access data on a target
    console.log(this.topBandThisWeekTarget.dataset.bandName);
    // Gojira
  }
}
```


```slim
div data-controller="entries-search" data-entries-search-categories-load-path="/band_search"
  div data-target="entries-search.topBandThisWeek" data-band-name="Gojira"

  .chip.hoverable data-action="click->entries-search#giveMeSomeData" data-favorite-band="Parkway Drive" Click This !
```




### Sources

* [How to use Rails.ajax in Stimulus Controllers](https://mikerogers.io/2020/01/29/how-to-use-rails-ujs-in-stimulus-controllers.html)
* [Stimulus case covention table](https://github.com/stimulusjs/stimulus/issues/70#issuecomment-359991756)
* alternative [Stimulous JS Cheat Sheet](https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e)
* [difference between event.target and event.currentTarget](https://discourse.stimulusjs.org/t/how-to-get-the-current-element-triggered/440)
* [accessing data on currentTarget (dataset)](https://discourse.stimulusjs.org/t/accessing-data-on-targets/602)
