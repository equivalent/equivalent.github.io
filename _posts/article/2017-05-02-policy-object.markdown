---
layout: article_post
categories: article
title:  "Policy Objects in Ruby on Rails"
disq_id: 41
description:
  Authorization (unlike Authentication) is really complex topic that may go wrong when using generic solutions. In this article I will show you how to write Policy Objects specific to your business logic.
redirect_from:
  - "/blogs/41"
  - "/blogs/41-policy-objects-in-ruby-on-rails"
---



Doing authentication (verifying if user is sign-in or not) in Ruby on Rails is quite easy.
You can [write your own simple authentication in Rails](http://www.eq8.eu/blogs/31-simple-authentication-for-one-user-in-rails) or you can use
[devise gem](https://github.com/plataformatec/devise) on any equivalent
and you are good to go.

When it comes to authorization (verifying if current_user has permission
to do stuff he/she is requesting to) it's a different topic. Yes there
are several solutions out there that works well on small project ([CanCanCan](https://github.com/CanCanCommunity/cancancan), [Rolify](https://github.com/RolifyCommunity/rolify),
...) but once your project grows to medium to large scale then these
generic solutions may become a burden.

In this article I will show you how you can do your Authorization with
policy object.

> Note: there is a gem [pundit](https://github.com/elabs/pundit) that has really nice plain Ruby
> policy object solution. But in this article we will write plain object
> solution for policies from scratch. If you're looking for a gem with established convention and community I recommend checking Pundit.

## Example

Let say in our application user can be:

* *regular user* that can only do read operations of public data of
  clients
* *moderator* for a particular Client that can edit client data and see
  private data for that client
* *admin* which means he will be able to do anything


The code in model could look like this:

```ruby
class Client < ActiveRecord::Base
  # ...
end
```

```ruby
class User < ActiveRecord::Base

  def admin?
    # ...
  end

  def moderator_for?(client)
    # ..
  end
end
```

We don't care how we retriving the information for these methods. It may
be relational DB flag, it may be  [Rolify](https://github.com/RolifyCommunity/rolify) `has_role?(:admin?)`.
It doesn't matter.

Usually when developers start implementing this to the application
logic they will do something like this.

```ruby
# app/controllers/clients_controllers.rb

class ClientsController < ApplicationController
  before_filter :authenticate_user! # Devise check if current user is sign_in or not (is he/she authenticated)
  before_filter :set_client

  def show
  end

  def edit
    if current_user.admin? || moderator_for?(@client)
      render :edit
    else
      render text: 'Not Authorized', status: 403
    end
  end

  # ...

  private

  def set_client
    @client = Client.find(params[:id])
  end
end
```

And in view


```erb
# app/views/clients/show.html.erb

Clients Name: <%= @client.name %>

<% if current_user.admin? || current_user.moderator_for?(@client) %>
  Clients contact: <%= @client.email %>
<% end %>
```

Now lets stop here and review. We have a code duplication in our
controller and our view for checking `current_user` role in this
scenario.

If business requirements change developers will have to change this in
multiple places. This is dangerous as he/she may skip a file and
introducing security vulnerability.

## Policy Object

It's crucial to keep your policy definitions in common place so that
other developers will have to change just one file in case the
requirement changes.

We will place our policy objects into folder `app/policy/`.

> Newer versions of Rails automaticly loads all `app/` subdirectories (
> [ref. 1](http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoload-paths), [ref. 2](https://github.com/equivalent/scrapbook2/pull/9#issue-229402335))
>
> Older versions of Rails will have to manually enable this directory like
> this:
>
> ```ruby
> module MyAppp
>   class Application < Rails::Application
>     # ...
>     config.autoload_paths << Rails.root.join('app', 'policy')
>     # ...
>   end
> end
> ```

And write our policy class:

```ruby
# app/policy/client_policy.rb
class ClientPolicy
  attr_reader :current_user, :resource

  def initialize(current_user:, resource:)
    @current_user = current_user
    @resource = resource
  end

  def able_to_moderate?
    current_user.admin? || current_user.moderator_for?(resource)
  end
end
```

Our controller will look like this:

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_client

  def show
  end

  def edit
    if client_policy.able_to_moderate?
      render :edit
    else
      render text: 'Not Authorized', status: 403
    end
  end

  # ...

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_policy
    @client_policy ||= ClientPolicy.new(current_user: current_user, resource: @client)
  end
  helper_method :client_policy
end
```

And our view `app/views/clients/show.html.erb` like:

```erb
Clients Name: <%= @client.name %>

<% if client_policy.able_to_moderate? %>
  Clients contact: <%= @client.email %>
<% end %>
```

Now beauty of this is that you have single place where you keep your
policy definitions (so if a new requirement comes it's easy to change)
and you've removed responsibility from controller to know policy
implementation, therefore it's easier to test.

Here is a test example:


```ruby
# spec/policy/client_policy_spec.rb
require 'rails_helper'

RSpec.describe ClientPolicy do
  subject { described_class.new(current_user: user, resource: client }
  let(:client) { Client.new } # feel free to use factory_girl gem on this

  context 'when current user regular user' do
    let(:user) { User.new }

    it { expect(subject).not_to be_able_to_moderate }
  end

  context 'when current user is an admin' do
    let(:user) { User.new admin: true }

    it { expect(subject).to be_able_to_moderate }
  end

  context 'when current user is a client moderator' do
    let(:user) { User.new.tap { |u| u.moderable_clients << client } }

    it { expect(subject).to be_able_to_moderate }
  end

  context 'when current user is unrelated client moderator' do
    let(:user) { User.new.tap { |u| u.moderable_clients << Client.new } }

    it { expect(subject).not_to be_able_to_moderate }
  end
end
```

> more on this style of test in article  [expressive rspec - part 1](http://www.eq8.eu/blogs/39-expressive-tests-with-rspec-part-1-describe-your-tests-properly)

As we are testing various Authorization scenarios in our policy object
test, all we need to test in our controller is that policy object
calls the policy method that our controller action desires.

```ruby
# spec/controllers/clients_controller.rb
require 'rails_helper'

RSpec.describe ClientsController do
  let(:client) { create :client }
  # ...

  describe 'GET edit' do
    def trigger; get :edit, id: client.id end


    context 'not logged in' do
      it 'should not access this page' do
        trigger
        expect(response.status).to eq 401 # not authenticated, e.g.: Devise restriction
      end
    end

    context 'logged in' do
      let(user) { User.new }
      let(:policy_double) { instance_double(ClientPolicy) }

      before do
        sign_in(user)

        expect(ClientPolicy)
          .to receive(:new).with(current_user: user, resource: client)
          .and_return(policy_double)
        expect(policy_double).to_receive(:able_to_moderate).and_return(policy_result)
      end

      context 'as authorized user' do
        let(:policy_result) { true }

        it 'should allow page render' do
          trigger
          expect(response.status).to eq 200
        end
      end

      context 'as non-authorized user' do
        let(:policy_result) { false }

        it do
          trigger
          expect(response.status).to eq 403
        end
      end
    end
  end

  # ...
end
```

## Scopes

Ok let say we have a requirement that on our `#index` page we can only list clients that
have `public` flag or that current_user can moderate.

If we put all the logic in controller the code may look like this:

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  # ...

  def index
    if current_user.admin?
      @clients = Client.all
    elsif current_user.clients.any?
      @clients = current_user.clients
    else
      @clients = Client.where(public: true)
    end
  end

  # ...
end
```

Let's introduce Policy Scope:


```ruby
# app/policy/client_policy.rb
class ClientPolicy
  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user:, scope:)
      @current_user = current_user
      @scope = scope
    end

    def displayable
      return scope if current_user.admin?

      if current_user.clients.any?
        scope.where(id: current_user.clients.pluck(:id))
      else
        scope.where(public: true)
      end
    end
  end

  # ...
end
```

```ruby
# app/controllers/clients_controllers.rb
class ClientsController < ApplicationController
  # ...

  def index
    @clients = Client.all
    @clients = ClientPolicy::Scope
                 .new(current_user: current_user, scope: @clients)
                 .displayable

    # you can implement more scopes e.g. @clients.order(:created_at)
    # or @clients pagination

    # ...
  end

  # ...
end
```

> This kind of objects are called Query Policy Objects. To learn more what they are and how to test them  I recommend my article  [Rails scopes composition and query objects](http://www.eq8.eu/blogs/38-rails-activerecord-relation-arel-composition-and-query-objects)


## Getting complex

Here is an example of real world complex policy object:

```ruby
# app/policy/client_policy.rb
class ClientPolicy
  attr_reader :current_user, :resource

  def self.able_to_list?(current_user)
    current_user.approved?
  end

  def initialize(current_user:, resource:)
    @current_user = current_user
    @resource = resource
  end

  def able_to_view?
    resource.id.in?(public_client_ids) || internal_user
  end

  def able_to_update?
    moderator?
  end

  def able_to_delete?
    moderator?
  end

  def as_json
    {
      view: able_to_view?,
      edit: able_to_edit?,
      delete: able_to_delete?
    }
  end

  private

  def admin?
    current_user.has_role(:admin)  # in this case we use Rolify style to determin admin
                                   # just to demonstrate the flexibility
  end

  def internal_user
    admin? || current_user.clients.any?
  end

  def moderator?
    current_user.admin? || current_user.moderator_for?(resource)
  end

  def public_client_ids
    Rails.cache.fetch('client_policy_public_clients', expires_in: 10.minutes) do
      Client.all.pluck(:id)
    end
  end
end
```

There is lot happening here. First we have methods that fully represent
CRUD actions on our controller `able_to_view?`, `able_to_update?`,
`able_to_delete?`. 

so our controller could look like:


```ruby
class ClientsController < ApplicationController
  NotAuthorized = Class.new(StandardError)

  rescue_from NotAuthorized do |e|
    render json: {errors: [message: "403 Not Authorized"]}, status: 403
  end

  def index
    raise NotAuthorized unless ClientPolicy.able_to_list?(current_user)
    @clients = Client.all
    @clients = ClientPolicy::Scope.new(scope: @clients, current_user: current_user)
    @clients # .order,  .per_page, ...
    # ...
  end

  # ...
  def show
    raise NotAuthorized policy.able_to_view?
    # ...
  end

  def edit
    raise NotAuthorized policy.able_to_update?
    # ...
  end

  def update
    raise NotAuthorized policy.able_to_update?
    # ...
  end

  def delete
    raise NotAuthorized policy.able_to_delete?
    # ...
  end
  # ...
end
```

> Don't mind that we have duplicate code in our Policy. `able_to_update?`
> and `able_to_delete?` are doing the same but it's the business
> representation that is valuable to us. If our requirements change that
> only admin can delete records we change only policy class not the
> controller.

As for `#index` action there is no particular one resource we can do
Authorization on. In this case we have a requirement that only
`activated` users can list clients. So we can call class method policy
where we just pass `current_user`.

When it comes to deciding which `@clients` can `current_user` actually see
we will use Policy Scope Object as we described in section above.

But let say if the policy would say "only **internal users** can list
clients" ...you can just initialize policy without passing resource and call
non-resource based methods:

```ruby
# app/controllers/clients_controller.rb
# ...

  def index
    index_policy = ClientPolicy.new(current_user: current_user)  # no resource is passed to initialivation, this is ok in this case.
    raise NotAuthorized unless index_policy.able_to_list?
  # ...
# ...

# app/policy/client_policy.rb
class ClientPolicy
  # ...
  able_to_list?
    internal_user
  end
  # ...
```

...you are initializing "incomplete object" but that's ok, as you are
aware that for that one interface call you don't need resource.

Moving on to another point.

Next interesting thing is `#public_client_ids` method. We are using
adventage of [Rails model caching](http://guides.rubyonrails.org/caching_with_rails.html). Now 
for this particular case it may seem unecessary, but let say we are
doing some really complex SQL to fetch the client ids or we call
microservice:


```ruby
class ClientPolicy
  # ...
  def public_client_ids
    Rails.cache.fetch('client_policy_public_clients', expires_in: 10.minutes) do
      body = HTTParty.get('http://my-micro-service.com/api/v1/public_clients.json')
      JSON.parse(body)
    end
  end
  # ...
end
```

As you can see Policy Object can take care of external policy calls too.

Last this I want to show you is the `#as_json` method

Imagine you have Frontend framework that is supose to display button if
given user is able to do particular action. I've seen many times that
BE will just pass flags as `user.admin==true` or
`user.moderator_for=[1,2,3]` to Frontend and developers have to replicate
exactly same policy logic with FE framework.

What you can do instead is create current user endpoint where you
already evaluate this logic for Frontend:

```ruby
# app/controller/current_user_controller.rb
class CurrentUser < ApplicationController
  def index
    roles = {}
    roles.merge!(client_policy_json) if client
    roles.merge!(some_other_roles)
    render json: roles
  end

  private

  def client_policy_json
    ClientPolicy
      .new(current_user: current_user, resource: client)
      .as_json
  end

  def client
    if params[:client_id]
      Client.find(params[:client_id])
    end
  end

  def some_other_roles
    { can_display_admin_link: false }
  end
end
```

`GET /current_user?client_id=1234`

...or you can just include this roles in same call as when you retriving
client data.

The point is BE Policy objecs can really make your team life better.

## Experimental - Policy Objects as Models Values Objects

Some developers may hate the fact that they need to initialize new
instance of policy object in controller. If that's so there is a different flavor of
Policy Objects.

```ruby
# app/model/appreciation.rb
class Appreciation < ApplicationRecord::Base
  # ...

  def policy
    @policy ||= AppreciationPolicy.new.tap { |ap| ap.resource = self }
  end
end

# app/policy/appreciation_policy.rb
class AppreciationPolicy
  attr_accessor :resource

  def can_be_destroyed?(by: )
    by && resource.user == by
  end
end


# app/controllers/appreciations_controller.rb
class AppreciationsController < ApplicationController
  # ...
  def destroy
    @appreciation = Appreciation.find(params[:id])
    raise NotAuthorized unless @appreciation.policy.can_be_destroyed?(by: current_user)
    # ...
  end
end
```

I don't have much experience with this style as I've played with them just in my [Ruby Rampage entry project](https://github.com/crazy-monkey-woodoo-priest/open-thanks) but
they feel quite ok. I like the fact that the code style is more
functional and explicit.

I'm just worried about caching and memoization of
related data. Where in Policy Objects it's easy to cache anything (as
you pass current user to object) with Policy Object as Value Object you
need to be careful not to cache data for only one user.

## Domain logic not CRUD

Ok so far it may sound like policy objects are all about CRUD and
you will need policy object for every model/controller. Well that's not true.

The only reason why I've chose to demonstrate policy objects from CRUD
controller perspective is because it's easier to understand them coming from other
solutions like CanCanCan. In reality you may write methods in policy
objects that has nothing to do with controller actions.

Policy objects are all about your domain logic not CURD:

```ruby
class ArticlePolicy
  attr_reader :current_user, :resource

  def initialize(current_user:, resource:)
    @current_user = current_user
    @resource = resource
  end

  # ...
  def able_to_view?
    resource.published? || current_user.admin?
  end

  def able_to_comment?
    able_to_view?
  end
end
```

```ruby
class CommentsController < ApplicationController
  # ...
  def create
    @article = Article.find(:article_id)
    raise NotAuthorized unless ArticlePolicy.new(current_user: current_user, resource: @article).can_comment?
    @article.create(article_params)
  end
  # ...
end
```

```
POST /articles/123/comments
```

You see, it may sense to create own `CommentPolicy` but if you don't
have enough requirements it may be just part of `ArticlePolicy`. When
time comes you can refactor it out to own class.

Be aware to not go too overboard with sticking too many responsibilities
to one policy object. The largest I ever had had maybe 7 public methods.


> **Update:** Recently we had code requirement change that we allow
> `document` to be deleted from a controller (as previously this was not
> possible). Before the change policy object had method
> `document_policy.able_to_delete_resorce?` with meaning that you can delete `resource`
> associations on a `document`.
>
> Colleague used this method
> for the `DocumentController` deletion action. Now the code was by coincident doing
> the thing he needed form the policy so implementation on security
> level was ok. But here is the thing: Now you have
> `document.resource.destroy if document_policy.able_to_delete_resorce?` and `document.destroy if document_policy.able_to_delete_resorce?`
> Imagine a Junior developer not aware of this comes and change to new
> requirement that "any user" can remove `document.resource` in the
> `DocumentPolicy` ...Now due to code design any user can remove any document.
>
> My argument was that we need a new method in `document_policy` object
> called `able_to_delete?` so that we would end up with:
> `document.resource.destroy if document_policy.able_to_delete_resorce?` and `document.destroy if document_policy.able_to_delete?`
>
> The methods inside the `DocumentPolicy` can be alias to each other
> until we decide to refactor them. The point that both methods represent
> different business requirement question on a policy object.
>
> Don't think about policy objects as just logic holders. During
> implementation in controller always ask them a human question. In this
> case: "Can I delete resorce of that document ?", "Can I delete a document?" and if there is a method matching
> that question in policy object implement it otherwise it's missing and
> you need to implement it.

Generic rule is:

*Policy Objects (when done right) don't force your application to map a solution.
They map your application requirements and your domain language. When your
requirements change they must be super easy to change as well, otherwise
you missed something and you are doing it wrong.*

## Dude Policy gem

2020-04-13 I've relased a gem [Dude Policy](https://github.com/equivalent/dude_policy) which provides a way to do Policy Objects
from perspective of a current_user current_account

```ruby
# rails console
article = Article.find(123)
review  = Review.find(123)
current_user = User.find(432) # e.g. Devise on any authentication solution

current_user.dude.able_to_edit_article?(article)
# => true

current_user.dude.able_to_add_article_review?(article)
# => true

current_user.dude.able_to_delete_review?(review)
# => false
```

```ruby
# spec/any_file_spec.rb
RSpec.describe 'short demo' do
  let(:author_user)  { User.create }
  let(:article) { Article.create(author: author_user) }
  let(:different_user)  { User.create }

  # you write tests like this:
  it { expect(author_user.able_to_edit_article?(article)).to be_truthy }

  # or you can take advantage of native `be_` RSpec matcher that converts any questionmark ending method to matcher
  it { expect(author_user).to be_able_to_edit_article(article) }
  it { expect(different_user).not_to be_able_to_edit_article(article) }
  it { expect(author_user).not_to be_able_to_add_article_review(article) }
  it { expect(different_user).to be_able_to_add_article_review(article) }
  it { expect(author_user).not_to be_able_to_delete_review(article) }
  it { expect(different_user).to be_able_to_add_article_review(article) }
end
```


I'm doing policy objects this way for couple of years now and I highly
recommend this as a solution for Policy Objects as it [solves many
problems ](https://github.com/equivalent/dude_policy#philospophy)

## Related articles

mine:

* <http://www.eq8.eu/blogs/38-rails-activerecord-relation-arel-composition-and-query-objects>
* <http://www.eq8.eu/blogs/31-simple-authentication-for-one-user-in-rails>
* <http://www.eq8.eu/blogs/39-expressive-tests-with-rspec-part-1-describe-your-tests-properly>
* <http://www.eq8.eu/blogs/31-simple-authentication-for-one-user-in-rails>
* <http://www.eq8.eu/blogs/30-pure-rspec-json-api-testing>
* example project using Policy Objects as model Value Objects <https://github.com/crazy-monkey-woodoo-priest/open-thanks>

external:

* <http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/>
* <https://github.com/elabs/pundit>

Reddit discussion on article:

* <https://www.reddit.com/r/ruby/comments/6a0qzz/policy_objects_in_ruby_on_rails/>


## Updates:

* 2017-05-09 added section "Domain logic not CRUD"
* 2017-05-09 added section "Policy Objects as Model Value Objects"
* 2017-05-09 in section "Getting Complex" I've added `ClientsController#index` example + policy
* 2017-05-09 I've received feedback that I didn't explain why I think  Plain Object solution is better that CanCanCan or just sticking roles
  directly to `User` model. That's true. In the past I've received lot
  of feedback that my articles are too long till they get to the point, that's why I've decided to
  skip explaining reasons and just show you how to do advanced stuff.
   I'm preparing more detailed step by step article where I'll explain my reasons more.
* 2017-05-24 added an `able_to_delete?` and `able_to_delete_resource?` to  "Domain logic not CRUD" section
* 2020-04-13 added `dude_policy` gem section


