# frozen_string_literal: true

require 'devise/jwt/revocation_strategies/redis' # Adjust the require path as necessary
require 'redis'

RSpec.describe Devise::Jwt::RevocationStrategies::Redis do
  let(:user) { double('User', id: 1) }
  let(:payload) { { 'jti' => 'some_unique_identifier' } }
  let(:payload2) { { 'jti' => 'some_unique_identifier' } }

  it "has a version number" do
    expect(Devise::Jwt::RevocationStrategies::Redis::VERSION).not_to be nil
  end

  before do
    # Stub the Redis connection
    $redis_auth = Redis.new(url: ENV.fetch('REDIS_AUTH_URL', 'redis://localhost:6379/0'))
    $redis_auth.set("jwt:#{payload['jti']}", 'revoked') # Simulate that the JWT exists
    $redis_auth.set("jwt:#{payload2['jti']}", 'revoked') # Simulate that the JWT exists
  end

  describe '.jwt_revoked?' do
    context 'when the JWT has been revoked' do
      it 'returns true' do
        $redis_auth.del("jwt:#{payload['jti']}") # Simulate revocation

        expect(described_class.jwt_revoked?(payload, user)).to be true
      end
    end

    context 'when the JWT has not been revoked' do
      it 'returns false' do
        expect(described_class.jwt_revoked?(payload, user)).to be false
      end
    end

    context 'when payload is invalid' do
      it 'handles missing jti gracefully' do
        invalid_payload = {}
        expect { described_class.jwt_revoked?(invalid_payload, user) }.not_to raise_error
        expect(described_class.jwt_revoked?(nil, user)).to be true
      end

      it 'handles nil jwt gracefully' do
        expect { described_class.jwt_revoked?(nil, user) }.not_to raise_error
        expect(described_class.jwt_revoked?(nil, user)).to be true
      end
    end
  end

  describe '.revoke_jwt' do
    it 'revokes the JWT and logs the revocation' do
      described_class.revoke_jwt(payload, user)

      expect($redis_auth.exists("jwt:#{payload['jti']}")).to eq 0
    end

    it 'revokes the nil JWT' do
      expect { described_class.revoke_jwt(nil, user) }.not_to raise_error
      expect(described_class.revoke_jwt(nil, user)).to be nil
    end

    it 'handles missing jti gracefully' do
      invalid_payload = {}
      expect { described_class.jwt_revoked?(invalid_payload, user) }.not_to raise_error
      expect(described_class.jwt_revoked?(invalid_payload, user)).to be true
    end
  end
end
