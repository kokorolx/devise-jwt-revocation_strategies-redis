# frozen_string_literal: true

require_relative "redis/version"
require_relative 'redis/jwt_dispatcher'
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

          redis_key = "jwt:#{payload['sub']}"  # Using user ID to get the Set
          !$redis_auth.sismember(redis_key, payload['jti'])
        end

        # Revokes a JWT by deleting its entry from Redis.
        #
        # @param payload [Hash] The payload of the JWT, which should include the 'jti' (JWT ID).
        # @param _user [Object] The user object (not used in this method).
        #
        # @return nil
        def self.revoke_jwt(payload, _user)
          user_id = payload['sub'] rescue nil
          jti = payload['jti'] rescue nil

          return if user_id.nil?

          redis_key = "jwt:#{user_id}"
          $redis_auth.srem(redis_key, jti)  # Remove the specific JWT from the Set
        end

        def self.revoke_all_jwts_for_user(user_id)
          redis_key = "jwt:#{user_id}"
          $redis_auth.del(redis_key)  # Delete the entire Set to revoke all tokens
        end
      end
    end
  end
end
