---
layout: til_post
title:  "Stimulus async load Rails HTML - `Rails.ajax` the RJS (format.js) way (full)"
categories: til
disq_id: til-79
---

or: How to load Rails HTML content with Stimulus JS using good old Rails format.js, .js.erb files  without any JSON woodoo


This is subarticle of [Stimulus JS Cheat Sheet](https://blog.eq8.eu/til/stimulus-js-cheat-sheet.html)


I also wrote [`Rails.ajax` the `render_to_string`way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-render_to_string-way-full.html) (so exact oposit of this solution)



### Rails stuff

```ruby
# config/routes.rb
# ...
resources :entries_search, only: [] do
  post :load_sub_category, on: :collection
end
# ...
```


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

if @main_category
  $('#sub-categories').html("<%= j(render('entries_search/categories')) %>");
else
  alert('Error: no Category match this ID');
end
```


### JS stuff

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
  loadSubCategories(e) {
    let categoriesLoadPath = this.data.get('categories-load-path');
    let mainCategoryId = e.currentTarget.dataset.mainCategoryId;

    Rails.ajax({
      type: "post",
      url: categoriesLoadPath,
      data: `main_category_id=${mainCategoryId}`,
    })
  }
}
```

Note how  in `Rails.ajax` we don't do the `success:` or `error:` parts.

With RJS the success / error is being handled by the JS response comming
from Rails controller response.

e.g. if there is success `.js.erb` file relpace the HTML content of element with
independent JS execution outside Stimulous controller. Same apply for errors response.



### Other sources

* [Stimulus JS Cheat Sheet](https://blog.eq8.eu/til/stimulus-js-cheat-sheet.html)
* [`Rails.ajax` the `render_to_string`way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-render_to_string-way-full.html)
* [`Rails.ajax` the RJS (`format.js`) way](https://blog.eq8.eu/til/stimulus-async-load-rails-html-railsajax-the-rjs-formatjs-way-full.html)

