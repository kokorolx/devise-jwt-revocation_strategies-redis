require 'json'
require 'active_support/concern'

module Devise
  module Jwt
    module RevocationStrategies
      module Redis
        module JwtDispatcher
          extend ActiveSupport::Concern

          included do
            def on_jwt_dispatch(token, payload)
              raise ArgumentError, 'payload cannot be nil' if payload.nil?

              jti = payload['jti']
              save_token_in_redis(jti, payload['sub'], payload['exp'])
            end
          end

          private

          def save_token_in_redis(jti, user_id, exp)
            raise ArgumentError, 'sub cannot be nil' if user_id.nil? || user_id.empty?
            raise ArgumentError, 'jti cannot be nil' if jti.nil? || jti.empty?
            raise ArgumentError, 'exp cannot be nil' if exp.nil?

            redis_key = "jwt:#{jti}"
            redis_value = { user_id: user_id }.to_json
            $redis_auth.set(redis_key, redis_value)
            $redis_auth.expireat(redis_key, exp)
          end
        end
      end
    end
  end
end