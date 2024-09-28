# frozen_string_literal: true

require_relative "lib/devise/jwt/revocation_strategies/redis/version"

Gem::Specification.new do |spec|
  spec.name = "devise-jwt-revocation_strategies-redis"
  spec.version = Devise::Jwt::RevocationStrategies::Redis::VERSION
  spec.authors = ["kokorolx"]
  spec.email = ["kokoro.lehoang@gmail.com"]

  spec.summary       = 'A gem to revoke JWT tokens using Redis for Devise.'
  spec.description   = 'This gem provides a strategy for revoking JWT tokens in a Rails application using Devise, utilizing Redis for token storage and revocation management.'
  spec.homepage = "https://github.com/kokorolx/devise-jwt-revocation_strategies-redis"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'redis'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
