require 'spec_helper'

describe Hatena::Credentials do

  before do
    @credentials = Hatena::Credentials.new(
      "consumer_key",
      "consumer_secret",
      "token",
      "token_secret"
    )
  end

  describe ".new" do
    context "when argument count is corrcet" do
      it "does not raise an error" do
        expect { Hatena::Credentials.new(0,1,2,3) }.not_to raise_error
      end
    end

    context "when argument count is incorrcet" do
      it "does not raise an error" do
        expect { Hatena::Credentials.new }.to raise_error
      end
    end
  end

  it "respond to these attributes and methods" do
    expect(@credentials).to respond_to(:consumer_key)
    expect(@credentials).to respond_to(:consumer_secret)
    expect(@credentials).to respond_to(:token)
    expect(@credentials).to respond_to(:token_secret)
    expect(@credentials).to respond_to(:auth_header)
  end
  
end

