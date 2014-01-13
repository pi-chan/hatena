require 'simple_oauth'

module Hatena
  class Credentials
    attr_reader :consumer_key, :consumer_secret, :token, :token_secret

    def initialize(consumer_key, consumer_secret, token, token_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @token = token
      @token_secret = token_secret
    end

    def auth_header(method, uri)
      SimpleOAuth::Header.new(method.to_sym, uri, {}, credential_hash).to_s
    end

    private

    def credential_hash
      {
        consumer_key:@consumer_key,
        consumer_secret:@consumer_secret,
        token:@token,
        token_secret:@token_secret
      }
    end
    
  end
  
end
