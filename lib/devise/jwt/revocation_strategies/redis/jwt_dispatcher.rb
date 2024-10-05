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

              save_token_in_redis(payload)
            end
          end

          private

          def save_token_in_redis(payload)
            raise ArgumentError, 'sub cannot be nil' if payload['sub'].blank?
            raise ArgumentError, 'jti cannot be nil' if payload['jti'].blank?
            raise ArgumentError, 'exp cannot be nil' if payload['exp'].blank?

            redis_key = Devise::Jwt::RevocationStrategies::Redis::Generator.redis_key(payload)
            $redis_auth.sadd(redis_key, "#{payload['jti']}:#{payload['d_name']}")
            $redis_auth.expireat(redis_key, payload['exp'])
          end
        end
      end
    end
  end
end
