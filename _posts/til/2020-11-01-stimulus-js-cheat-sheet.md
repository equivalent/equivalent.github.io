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

### Target names

`cammelCase`


```js
// app/javascript/controllers/entries_search_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "awesomeBands" ]

  fillAwesomeBands() {
    this.awesomeBands.innerHTML = "Atreyu, Deadlock, Trivium';
  }
}
```


```html
<div data-target="entries-search.awesomeBands">
<div data-action="click->entries-search#fillAwesomeBands">Want to know awesome bands?</div>
```

```slim
div data-action="click->entries-search#makeRequest"

.chip.hoverable data-action="click->entries-search#makeRequest"
```


### Lifecycle

```js
import { Controller } from "stimulus"

export default class extends Controller {

  initialize () {
    // is called once per controller
  }

  connect () {
    // is called evvery time the controller is connected to the DOM.
  }

  disconnect () {
    // called when controller element is removed from the document:
  }
}
```

sources:
* [Stimulus initialize vs connect](https://github.com/stimulusjs/stimulus/issues/75#issuecomment-361255170)



## Set data on controller

* `this.data.has("melodicDeathMetalBand")` returns true if the controller’s element has a `data-entries-search-melodic-death-metal-band` attribute
* `this.data.get("melodicDeathMetalBand")` returns the string value of the element’s `data-entries-search-melodic-death-metal-band` attribute
* `this.data.set("melodicDeathMetalBand", "Deadlock")`     sets the element’s `data-entries-search-melodic-death-metal-band` attribute to the string value of "Deadlock"

stolen from: [Stimulus cheatsheet by mrmartineau](https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e#data-api)

## How to fetch data values on various levels

```js
// app/javascript/controllers/entries_search_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  giveMeSomeData(event) {
    // Access the Controller data
    console.log(this.data.get('categoriesLoadPath'));
    // => /band_search
    //
    // note: `console.log(this.data.get('categories-load-path'));` also works


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


## How to use `Rails.ajax` to async replace HTML content with Stimulus JS

There is 2 ways how to do it. The RJS way or the `render_to_string` way.
Both are equally fine, it's just matter of taste.

I wrote separate notes explaining how to do each approach:

* [`Rails.ajax` the `render_to_string`way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-render_to_string-way-full.html)
* [`Rails.ajax` the RJS (`format.js`) way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-rjs-formatjs-way-full.html)




## Sources

* [How to use Rails.ajax in Stimulus Controllers](https://mikerogers.io/2020/01/29/how-to-use-rails-ujs-in-stimulus-controllers.html)
* [Stimulus case covention table](https://github.com/stimulusjs/stimulus/issues/70#issuecomment-359991756)
* alternative [Stimulous JS Cheat Sheet](https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e)
* [difference between event.target and event.currentTarget](https://discourse.stimulusjs.org/t/how-to-get-the-current-element-triggered/440)
* [accessing data on currentTarget (dataset)](https://discourse.stimulusjs.org/t/accessing-data-on-targets/602)

* [how to use Rails.ajax](https://www.rubyguides.com/2019/03/rails-ajax/)

* <https://www.rubyguides.com/2019/03/rails-ajax/>
* [Stimulus JS Cheat Sheet](https://blog.eq8.eu/til/stimulus-js-cheat-sheet.html)
* [`Rails.ajax` the `render_to_string`way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-render_to_string-way-full.html)
* [`Rails.ajax` the RJS (`format.js`) way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-rjs-formatjs-way-full.html)

