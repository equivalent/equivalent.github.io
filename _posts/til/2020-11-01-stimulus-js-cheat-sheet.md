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


## How to use `Rails.ajax` to async replace HTML content with Stimulus JS

There is 2 ways how to do it. The RJS way or the `render_to_string` way.
Both are equally fine, it's just matter of taste

#### `Rails.ajax` the `render_to_string` way

```ruby
# /app/controllers/entries_search_controller.rb
class EntriesSearchController < ApplicationController
  def load_sub_category
    @main_category = Category.find(params[:main_category_id])

    render json: { html: render_to_string(partial: 'entries_search/categories') }
  end
end
```

```ruby
# config/routes.rb
# ...
resources :entries_search, only: [] do
  post :load_sub_category, on: :collection
end
# ...
```

```slim
-# /app/views/entries_search/index.html.slim
div data-controller="entries-search" data-entries-search-categories-load-path="#{load_sub_categories_entries_search_index_path}"
  div data-target="entries-search.categories"

.chip.hoverable data-action="click->entries-search#loadSubCategories" data-main-category-id="123"
   | Load "Puppies" Sub Categories
.chip.hoverable data-action="click->entries-search#loadSubCategories" data-main-category-id="345"
   | Load "Kittens" Sub Categories
```

> note: `load_sub_categories_entries_search_index_path` is being translated to  `/entries_search/load_sub_categories` by Rails routes

```slim
-# /app/views/entries_search/_categories.html.slim
- @main_category.sub_categories.each do |sub_category|
  .chip= sub_category.title
```

```js
//packaje.json
{
  "dependencies": {
    # ...
    "@rails/ujs": "^6.0.0-alpha",
    "stimulus": "^1.1.1",
    # ...
  }
}

```

```js
import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "categories" ]

  loadSubCategories(e) {
    let categoriesLoadPath = this.data.get('categories-load-path');
    let mainCategoryId = e.currentTarget.dataset.mainCategoryId;
    let categoriesTargetDiv = this.categoriesTarget;

    Rails.ajax({
      type: "post",
      url: categoriesLoadPath,
      data: `main_category_id=${mainCategoryId}`,
      success: function(data) { categoriesTargetDiv.innerHTML = data.html; }
    })
  }
}
```



#### `Rails.ajax` the RJS (`format.js') way


```ruby
# /app/controllers/entries_search_controller.rb
class EntriesSearchController < ApplicationController
  def load_sub_category
    @main_category = Category.find(params[:main_category_id])

    respond_to do |format|
      format.js { render  'load_sub_category' }
    end
  end
end
```

```ruby
# config/routes.rb
# ...
resources :entries_search, only: [] do
  post :load_sub_category, on: :collection
end
# ...
```

```slim
-# /app/views/entries_search/index.html.slim
div data-controller="entries-search" data-entries-search-categories-load-path="#{load_sub_categories_entries_search_index_path}"
  #sub-categories
    -# here the response will get loaded

.chip.hoverable data-action="click->entries-search#loadSubCategories" data-main-category-id="123"
   | Load "Puppies" Sub Categories
.chip.hoverable data-action="click->entries-search#loadSubCategories" data-main-category-id="345"
   | Load "Kittens" Sub Categories
```

> note: `load_sub_categories_entries_search_index_path` is being translated to  `/entries_search/load_sub_categories` by Rails routes

```slim
-# /app/views/entries_search/_categories.html.slim
- @main_category.sub_categories.each do |sub_category|
  .chip= sub_category.title
```

```erb
// /app/views/entries_search/load_sub_categories.js.erb
$('#sub-categories').html("<%= j(render('entries_search/categories')) %>");
```

```js
//package.json
{
  "dependencies": {
    # ...
    "@rails/ujs": "^6.0.0-alpha",
    "stimulus": "^1.1.1",
    # ...
  }
}

```

```js
import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ "categories" ]

  loadSubCategories(e) {
    let categoriesLoadPath = this.data.get('categories-load-path');
    let mainCategoryId = e.currentTarget.dataset.mainCategoryId;
    let categoriesTargetDiv = this.categoriesTarget;

    Rails.ajax({
      type: "post",
      url: categoriesLoadPath,
      data: `main_category_id=${mainCategoryId}`,
    })
  }
}
```





## Sources

* [How to use Rails.ajax in Stimulus Controllers](https://mikerogers.io/2020/01/29/how-to-use-rails-ujs-in-stimulus-controllers.html)
* [Stimulus case covention table](https://github.com/stimulusjs/stimulus/issues/70#issuecomment-359991756)
* alternative [Stimulous JS Cheat Sheet](https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e)
* [difference between event.target and event.currentTarget](https://discourse.stimulusjs.org/t/how-to-get-the-current-element-triggered/440)
* [accessing data on currentTarget (dataset)](https://discourse.stimulusjs.org/t/accessing-data-on-targets/602)

* [how to use Rails.ajax](https://www.rubyguides.com/2019/03/rails-ajax/)
