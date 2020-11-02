---
layout: til_post
title:  "Stimulus async load Rails HTML - `Rails.ajax` the `render_to_string` way (full)"
categories: til
disq_id: til-78
---


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

    render json: { html: render_to_string(partial: 'entries_search/categories') }
  end
end
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
// app/javascript/controllers/entries_search_controller.js
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
      success: function(data) { categoriesTargetDiv.innerHTML = data.html; },
      error: function(data) { alert('Error: no Category match this ID') },
    })
  }
}
```


### Other sources

* https://www.rubyguides.com/2019/03/rails-ajax/
