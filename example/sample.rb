require "rubygems"
$:.unshift File.expand_path "../lib", File.dirname(__FILE__)

require "hatena"
require "pry"

token = "token"
token_secret = "secret_token"
consumer_key = "key"
consumer_secret = "secret_key"
id = "your_id"

credentials = Hatena::Credentials.new(
  consumer_key,
  consumer_secret,
  token,
  token_secret
)

client = Hatena::Blog::Client.new(credentials, id, "#{id}.hatenablog.com")

drafts = client.fetch_drafts()
puts drafts
