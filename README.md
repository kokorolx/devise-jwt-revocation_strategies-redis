# Devise::Jwt::RevocationStrategies::Redis

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

### Configuration
- Setting up Redis
Ensure that you have Redis installed and running. You can configure the Redis connection URL in your environment variables. For example:
```#.env
REDIS_AUTH_URL=redis://localhost:6379/0
```

Setup your devise model:
```ruby
class User < ApplicationRecord
  include Devise::Jwt::RevocationStrategies::Redis::JwtDispatcher

  devise :database_authenticatable, # your enabled modules
         :jwt_authenticatable, jwt_revocation_strategy: Devise::Jwt::RevocationStrategies::Redis
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/devise-jwt-revocation_strategies-redis.
