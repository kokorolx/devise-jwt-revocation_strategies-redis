# frozen_string_literal: true

require 'redis'
require 'devise/jwt/revocation_strategies/redis/jwt_dispatcher' # Adjust the require path as necessary

RSpec.describe Devise::Jwt::RevocationStrategies::Redis::JwtDispatcher do
  let(:dummy_class) { Class.new { include Devise::Jwt::RevocationStrategies::Redis::JwtDispatcher } }
  let(:instance) { dummy_class.new }

  before do
    # Stub the Redis client
    $redis_auth = Redis.new(url: ENV.fetch('REDIS_AUTH_URL', 'redis://localhost:6379/0'))
  end

  describe '#on_jwt_dispatch' do
    let(:token) { 'fake_token' }
    let(:payload) { { 'jti' => '123', 'sub' => 'user_id', 'exp' => Time.now.to_i + 3600 } }

    it 'saves the JWT in Redis' do
      expect($redis_auth).to receive(:set).with("jwt:#{payload['jti']}", { user_id: payload['sub'] }.to_json)
      expect($redis_auth).to receive(:expireat).with("jwt:#{payload['jti']}", payload['exp'])

      instance.on_jwt_dispatch(token, payload)
    end

    context 'when payload is nil' do
      it 'does not attempt to save to Redis' do
        expect($redis_auth).not_to receive(:set)
        expect($redis_auth).not_to receive(:expireat)


        expect {
          instance.on_jwt_dispatch(token, nil)
        }.to raise_error(ArgumentError, 'payload cannot be nil')
      end
    end

    context 'when payload does not contain sub' do
      let(:payload) { { 'sub' => '', 'exp' => Time.now.to_i + 3600 } }

      it 'does not attempt to save to Redis' do
        expect($redis_auth).not_to receive(:set)
        expect($redis_auth).not_to receive(:expireat)

        expect { instance.send(:on_jwt_dispatch, token, payload) }.to raise_error(ArgumentError, 'sub cannot be nil')
      end
    end

    context 'when payload does not contain jti' do
      let(:payload) { { 'sub' => 'user_id', 'exp' => Time.now.to_i + 3600 } }

      it 'does not attempt to save to Redis' do
        expect($redis_auth).not_to receive(:set)
        expect($redis_auth).not_to receive(:expireat)

        expect { instance.on_jwt_dispatch(token, payload) }.to raise_error(ArgumentError, 'jti cannot be nil')
      end
    end

    context 'when payload does not contain exp' do
      let(:payload) { { 'jti' => '123', 'sub' => 'user_id' } }

      it 'does not attempt to save to Redis' do
        expect($redis_auth).not_to receive(:set)
        expect($redis_auth).not_to receive(:expireat)

        expect { instance.on_jwt_dispatch(token, payload) }.to raise_error(ArgumentError, 'exp cannot be nil')
      end
    end
  end

  describe '#save_token_in_redis' do
    let(:jti) { '123' }
    let(:user_id) { 'user_id' }
    let(:exp) { Time.now.to_i + 3600 }

    it 'sets the token in Redis with the correct key and value' do
      expect($redis_auth).to receive(:set).with("jwt:#{jti}", { user_id: user_id }.to_json)
      expect($redis_auth).to receive(:expireat).with("jwt:#{jti}", exp)

      instance.send(:save_token_in_redis, jti, user_id, exp)
    end
  end
end
