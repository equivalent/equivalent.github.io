---
layout: til_post
title:  "Factory Bot trait for attaching Active Storange has_attached"
categories: til
disq_id: til-50
---

How to add [Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html)
attachement as a [Factory Bot](https://github.com/thoughtbot/factory_bot)
(or Factory Girl) trait.


> technology used in the example: Rails 5.2.0, Ruby 2.5, Factory Bot 4.10, RSpec 3.7

```ruby
# app/models/account.rb
class Account < ActiveRecord::Base
  has_attached :image
end

# spec/rails_helper.rb
FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

# spec/factories/accounts.rb
FactoryBot.define do
  factory :account do
    name 'Tomas'

    trait :with_avatar do
      avatar { fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'test-image.png'), 'image/png') }
    end
  end
end
```

> make sure you have test image to spec/support/assets/test-image.png

Now you can do:

```ruby
# spec/models/account_spec.rb
let(:account) { build :account, :with_avatar)
let(:account) { build_stubbed :account, :with_avatar)
let(:account) { create :account, :with_avatar)
```


### Alternative way:


```ruby
# spec/factories/accounts.rb
FactoryBot.define do
  factory :account do
    name 'Tomas'

    trait :with_avatar do
      after :create do |account|
        file_path = Rails.root.join('spec', 'support', 'assets', 'test-image.png')
        file = fixture_file_upload(file_path, 'image/png')
        account.avatar.attach(file)
      end
    end
  end
end

# spec/models/account_spec.rb
let(:account) { create :account, :with_avatar)
```

> didn't try it but teoretically you can use this approach to attach
> has_many_attached

### Using Test Helpers

My favorit approach is to create helper module that would extend everything required
for attaching images:

```ruby
# spec/support/files_test_helper.rb
module FilesTestHelper
  extend self
  extend ActionDispatch::TestProcess

  def png_name; 'test-image.png' end
  def png; upload(png_name) end

  def jpg_name; 'test-image.jpg' end
  def jpg; upload(jpg_name) end

  def tiff_name; 'test-image.tiff' end
  def tiff; upload(tiff_name) end

  def pdf_name; 'test.pdf' end
  def pdf; upload(pdf_name) end

  private

  def upload(name)
    file_path = Rails.root.join('spec', 'support', 'assets', name)
    fixture_file_upload(file_path, 'image/png')
  end
end
```

```ruby
# spec/factories/accounts.rb
FactoryBot.define do
  factory :account do
    name 'Tomas'

    trait :with_avatar do
      avatar { FilesTestHelper.png }
    end
  end
end
```

This way I don't have to polute Factory Bot with: `FactoryBot::SyntaxRunner.class_eval { include ActionDispatch::TestProcess }`
making the debugging easier for junior developers.

And I'm also able to reuse the test helper e.g. in controler specs when testing upload:

```ruby
RSpec.describe V3::AccountsController, type: :controller do
  describe 'POST create' do
    let(:avatar) { FilesTestHelper.png }

    def trigger do
      post :create, params: { avatar: avatar, name: 'Zdenka' }
    end

    it 'should upload the file' do
      expect { trigger }.to change{ ActiveStorage::Attachment.count }.by(1)
    end

    it 'should create the account' do
      expect { trigger }.to change{ Account.count }.by(1)
			account = Account.last
      expect(account.avatar).to be_attached
      expect(account.avatar.filename).to eq FilesTestHelper.png_name
      expect(account.name).to eq 'Zdenka'
		end
	end
end
```

### Related articles:

* <https://blog.eq8.eu/til/ruby-on-rails-active-storage-how-to-change-host-for-url_for.html>
* <https://blog.eq8.eu/article/back-to-the-primitive-testing-with-simplicity.html>

### Discussion:

* <https://www.reddit.com/r/ruby/comments/950bni/factory_bot_trait_for_attaching_active_storange/>
* <http://www.rubyflow.com/p/2wfssa-how-to-add-active-storage-attachement-as-a-factory-bot-or-factory-girl-trait> 
