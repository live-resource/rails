# LiveResource::Rails

Rails does not have an elegant abstraction for defining resources that exist between requests.

Requesting a resource, for example, /profiles.json, is handled very well, and will route through the ProfilesController,
load the collection of Profile models, and render the index view (MVC).

The LiveResource gem adds the concept of a Resource, which is an object derived from server state (such as models) that
can be *pulled* (requested, as in the above example), or *pushed* when changes to server state are detected.

LiveResource-Rails adds support to Rails for defining and configuring live resources.

## Example

```ruby
# app/controllers/profiles_controller.rb

class ProfilesController < ApplicationController
  ...

  # show.json
  # {
  #   name: @profile.name,
  #   avatar: {
  #     alt_text: @profile.avatar.alt_text,
  #     url: avatar_url( @profile.avatar )
  #   }
  # }
  def show
    ...
  end

  live_resource :show do
    identifier { |profile| profile_path(profile) }

    # When a Profile instance is changed (requires live_resource-activerecord)
    depends_on(Profile) do |profile|
      # Push an update for the resource belonging to the profile
      push(profile)
    end

    # Since the view will change if the avatar changes, depend on that too
    depends_on(Avatar) do |avatar|
      push avatar.profile
    end
  end

  ...
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'live_resource-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install live_resource-rails

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

- Integration test with dummy Rails app (also as an example for getting started)
- Test injection of URL helpers in DSL into Builder