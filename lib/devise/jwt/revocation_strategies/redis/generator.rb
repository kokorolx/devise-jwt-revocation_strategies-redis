# frozen_string_literal: true

# Devise::Jwt::RevocationStrategies::Utils.redis_key
module Devise
  module Jwt
    module RevocationStrategies
      module Redis
        class Generator
          def self.redis_key(payload, prefix = 'jwt')
            "#{prefix}:#{payload['sub']}:#{payload['d_uuid']}"
          end

          def self.redis_value(payload, prefix = 'jwt', key = 'jti')
            p "====payload redis_value", payload
            "#{payload[key]}:#{payload['d_name']}"
          end
        end
      end
    end
  end
end