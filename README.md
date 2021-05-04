# Formify

## DEPRECATED

This project has been deprecated in favor of [ActiveInteraction](https://github.com/AaronLasseigne/active_interaction). No future updates will be made to this repo or gem.

[![Build Status](https://travis-ci.org/ryanwjackson/formify.svg?branch=master)](https://travis-ci.org/ryanwjackson/formify) [![Coverage Status](https://coveralls.io/repos/github/ryanwjackson/formify/badge.svg?branch=master)](https://coveralls.io/github/ryanwjackson/formify?branch=master)

Formify gives you scaffolding for quickly adding robust forms to your application.  Formify also includes rspec testing helpers, making it easy to validate forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formify

## Usage

Once installed, use `include Formify::Form` into any class to give it the form structure.  In rspec tests, you can `require 'formify/spec_helpers` and then `include Formify::SpecHelpers`.  This gives you access to [a number of helper methods](lib/formify/spec_helpers.rb).

## Generators

Formify ships with a powerful generator, giving you some default scaffolding.  It's designed to generate everything for you, letting you know what's optional and can be removed.  You can generate forms and their respective spec files using the following:

`rails generate form ATTRIBUTES`

`ATTRIBUTES` is a list of form attributes and their delegates.  Formify takes advantage of existing objects (e.g. models and other forms) and their attribute reading and writing functionality.  For example, if you were to do the following:

`rails generate form widgets/create foo:bar,baz owner:owner_attribute created_by`

You would get the following files:

- `app/lib/forms/widgets/create.rb`
- `spec/lib/forms/widgets/create_spec.rb`

### Generated Form

```ruby
# frozen_string_literal: true

module Forms
  module Widgets
    class Create
      include Formify::Form

      attr_accessor :created_by,
                    :foo,
                    :owner

      delegate_accessor :bar,
                        :baz,
                        to: :foo
      delegate_accessor :owner_attribute,
                        to: :owner

      validates_presence_of :bar,
                            :baz,
                            :created_by,
                            :foo,
                            :owner,
                            :owner_attribute

      # validate :validate_something

      initialize_with :created_by, :foo, :owner do |attributes|
        puts attributes
      end

      def save
        raise NotImplementedError

        with_advisory_lock_transaction(:foo) do
          validate_or_fail
            .and_then { create_widget }
            .and_then { success(created_by) }
        end
      end

      private

      def create_widget
      end

      # def validate_something
      # end
    end
  end
end
```

### Generated Spec

```ruby
# frozen_string_literal: true

require 'rails_helper'
require 'formify/spec_helpers'

describe Forms::Widgets::Create, type: :form do
  include Formify::SpecHelpers

  # :attributes is used to initialize the form.
  # These values should result in a valid form.
  # You can override these in blocks or use let(:attributes_override) { { foo: bar } }
  let(:attributes) do
    {
      bar: BAR_VALUE,
      baz: BAZ_VALUE,
      created_by: CREATED_BY_VALUE,
      foo: FOO_VALUE,
      owner: OWNER_VALUE,
      owner_attribute: OWNER_ATTRIBUTE_VALUE
    }
  end

  it { expect_valid } # Expect the form to be valid
  it { expect(result).to be_success }
  it { expect(value).to be_a(Widget) } # Model name inferred

  context '#bar' do
    it { expect_error_with_missing_attribute(:bar) }
    xit { expect_error_with_attribute_value(:bar, BAR_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:bar, BAR_GOOD_VALUE) }
  end

  context '#baz' do
    it { expect_error_with_missing_attribute(:baz) }
    xit { expect_error_with_attribute_value(:baz, BAZ_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:baz, BAZ_GOOD_VALUE) }
  end

  context '#created_by' do
    it { expect_error_with_missing_attribute(:created_by) }
    xit { expect_error_with_attribute_value(:created_by, CREATED_BY_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:created_by, CREATED_BY_GOOD_VALUE) }
  end

  context '#foo' do
    it { expect_error_with_missing_attribute(:foo) }
    xit { expect_error_with_attribute_value(:foo, FOO_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:foo, FOO_GOOD_VALUE) }
  end

  context '#owner' do
    it { expect_error_with_missing_attribute(:owner) }
    xit { expect_error_with_attribute_value(:owner, OWNER_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:owner, OWNER_GOOD_VALUE) }
  end

  context '#owner_attribute' do
    it { expect_error_with_missing_attribute(:owner_attribute) }
    xit { expect_error_with_attribute_value(:owner_attribute, OWNER_ATTRIBUTE_BAD_VALUE, message: nil) } # :message is optional
    xit { expect_valid_with_attribute_value(:owner_attribute, OWNER_ATTRIBUTE_GOOD_VALUE) }
  end

  # Other Expectation Helpers
  # xit { expect_error_message(message) }
  # xit { expect_error_with_attribute(attribute) }
  # xit { expect_not_valid(attribute: nil, message: nil) } # :attribute and :message are optional
end

```

### Options

- `pluralize_collection` (default: `true`) - Pluralize the collection as per naming conventions below.

## Transactions

Formify works with ClosureTree/with_advisory_lock to offer easy and intuitive locking, with or without transactions.

## Naming Conventions

### Form Name
Formify assumes that every form is an action.  As such, it's best to use verbs like `create`, `update`, `destroy`, `upsert`, `find`, `process`, etc.

### Form Collection
The parent folder of a form should be the plural of the object it operates on.  For example, if you had a `User` model, you would have `users/create.rb`.  The collection does not need to be a model.  It can be any noun in the plural form, like `sessions/create.rb`

### Collection Scopes

Any folder before the collection is considered a scope and serves to help you group collections and forms.  Consider an application that has a end-user and an admin, and accounts need to be approved.  You would probably consider the following actions to need separate functionality:

- `/forms/admin/accounts/create.rb` - This one may take an `approved_by` attribute.
- `/forms/accounts/create.rb` - This one would result in account pending approval

Scoping helps you keep your

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanwjackson/formify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Formify project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryanwjackson/formify/blob/master/CODE_OF_CONDUCT.md).
