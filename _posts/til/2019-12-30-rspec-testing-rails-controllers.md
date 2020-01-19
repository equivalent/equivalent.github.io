---
layout: til_post
title:  "RSpec Rails controllers test examples"
categories: til
disq_id: til-73
---

Here are some [RSpec](https://rspec.info/) examples on how I like to test [Ruby on Rails](https://rubyonrails.org/)
controllers


> I'll be adding more soon

## How I use controller tests

In my opinion controller specs should touch multiple layers of functionality
and serve as an integration tests.
Test like this  go hand in hand with [testing with primitives](https://blog.eq8.eu/article/back-to-the-primitive-testing-with-simplicity.html) philosophy

I agree that sometimes you need to do
mocks and stubs but overkill will come kick you or your teammates in the nuts one day.

![unit-test](/assets/2019/unit-test.jpg)

Reason why I don't use
[request specs](https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec) for this is that's is bit harder to debug
why the tests failed.

So in nutshell:

* I use Controller tests as pragmatic integration tests of multiple layers taht can cover 70% - 90% of the application
* I use request tests as more robust integration tests for functionality that "must work no matter what" like bank transactions.

Many collegues may disagree with this approach and that's fine. Whatever
works for your team don't just blindly follow what some idiot writes on
internet :)

> I have 10 years of experience with RoR seen many approaches many
> opinions, many fails and many victories. Only thing that matters when
> it comes to testing is if the team is happy and project works in 5 years time

## Test if Form was rendered


```ruby
# app/controllers/books_controller.rb
class BooksController < ApplicationController
  def review
    @book = Book.find(params[:id])
    # ...
    render :review
  end

  def submit_review
    # ...
  end
end

# config/routes.rb
resources :books, only: [] do
  get  :review, on: :member  # /books/123/review
  post :submit_review, on: :member  # /books/123/submit_review
end

# app/views/books/review.html.slim
= form_with(model: @book, url: submit_review_book_path(@book), method: :post) do |f|
  .input-field
    = f.label :description, for: "review_description"
    = f.text_field :description, id: "review_description", placeholder: 'totaly sux'


# spec/controllers/books_controller_spec.rb
require 'rails_helper'
RSpec.describe BooksController, type: :controller do

  describe '#review' do
    let(:book) { Book.create title: 'Whatever' }

    def trigger
      get :review, params: { id: book.id , format: format  }
    end

    context 'when html' do
      render_views # this is important it tels rails to render the views

      let(:format) { 'html' }

      it do
        trigger

        expect(response.code).to eq '200'

        assert_select "form[action='/books/#{book.id}/submit_review'][method='post']" do
          assert_select "input[type='text'][name='description'][id='review_description']"     # this means inside the form there is input
        end
      end
    end
  end
end
```

Notes:

[render_views](https://relishapp.com/rspec/rspec-rails/v/2-5/docs/controller-specs/render-views) tels RSpec to render the view in costroller

[assert_select](https://guides.rubyonrails.org/testing.html#implementing-an-integration-test)
is native Rails test thing and RSpec has [has_tag](https://github.com/dcuddeback/rspec-tag_matchers/blob/master/lib/rspec/tag_matchers/has_tag.rb)
but I like how dynamic assert_select feels. You can do stuff like this:

```ruby
assert_select "form:match('action', ?):match('method', ?)", "/books/#{book.id}/submit_review", 'post'
assert_select 'div.card-panel.red', "Cupon Expired"
```


