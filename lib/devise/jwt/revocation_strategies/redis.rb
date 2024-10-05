# frozen_string_literal: true

require_relative "redis/version"
require_relative 'redis/jwt_dispatcher'
require_relative 'redis/generator'
require 'redis'
require 'dotenv-rails'

module Devise
  module Jwt
    module RevocationStrategies
      module Redis
        Dotenv.load
        $redis_auth ||= ::Redis.new(url: ENV.fetch('REDIS_AUTH_URL') { 'redis://localhost:6379/0' })

        class Error < StandardError; end
        # Checks if the JWT has been revoked.
        #
        # @param payload [Hash] the payload of the JWT, which includes the 'jti' (JWT ID).
        # @param _user [Object] the user object (unused in this method).
        # @return [Boolean] true if the JWT has been revoked or if there is an error accessing Redis, false otherwise.
        def self.jwt_revoked?(payload, _user)
          return true if payload.nil? || payload['jti'].nil? || payload['sub'].nil?  # Check if JTI or user ID is nil

          redis_key = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_key(payload)
          redis_value = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_value(payload)
          # now we can logout per device, but if we have multiple devices, we wont know the device name to logout
          !$redis_auth.sismember(redis_key, redis_value)
        end

        # Revokes a JWT by deleting its entry from Redis.
        #
        # @param payload [Hash] The payload of the JWT, which should include the 'jti' (JWT ID).
        # @param _user [Object] The user object (not used in this method).
        #
        # @return nil
        def self.revoke_jwt(payload, _user = nil)
          user_id = payload['sub'] rescue nil

          return if user_id.nil?

          redis_key = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_key(payload)
          redis_value = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_value(payload)
          binding.pry

          $redis_auth.srem(redis_key, redis_value)  # Remove the specific JWT from the Set
        end

        # TODO: implement this method
        def self.revoke_all_jwts_for_user(user_id)
          # redis_key = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_key(payload)
          # $redis_auth.del(redis_key)  # Delete the entire Set to revoke all tokens
        end
      end
    end
  end
end
