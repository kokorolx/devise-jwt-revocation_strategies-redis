# frozen_string_literal: true

require_relative "redis/version"
require_relative 'redis/jwt_dispatcher'

module Devise
  module Jwt
    module RevocationStrategies
      module Redis
        class Error < StandardError; end
        # Checks if the JWT has been revoked.
        #
        # @param payload [Hash] the payload of the JWT, which includes the 'jti' (JWT ID).
        # @param _user [Object] the user object (unused in this method).
        # @return [Boolean] true if the JWT has been revoked or if there is an error accessing Redis, false otherwise.
        def self.jwt_revoked?(payload, _user)
          $redis_auth.exists("jwt:#{payload['jti']}") == 0 rescue true
        end

        # Revokes a JWT by deleting its entry from Redis.
        #
        # @param payload [Hash] The payload of the JWT, which should include the 'jti' (JWT ID).
        # @param _user [Object] The user object (not used in this method).
        #
        # @return nil
        def self.revoke_jwt(payload, _user)
          jti = payload['jti'] rescue nil

          return if jti.nil?

          $redis_auth.del("jwt:#{jti}") rescue nil
        end
      end
    end
  end
end
