require 'rubygems'
require 'sinatra'
require 'yaml'
require 'instagram'
require 'json'
require 'dalli'
require 'newrelic_rpm'
require 'redis'
require './parsers/instagram_parser'
require './publishers/posterous_publisher'
require './publishers/tumblr_publisher'

use Rack::Session::Cookie

set :cache, Dalli::Client.new

configure :development do
  keyfile = File.join(File.dirname(__FILE__), 'keys.yml')
  KEYS = YAML.load(File.read(keyfile)) if File.exists?(keyfile)
  CALLBACK_URL    = "http://localhost:4567/oauth/callback"
  CLIENT_ID       = KEYS['instagram']['client_id']
  CLIENT_SECRET   = KEYS['instagram']['client_secret']
  POSTEROUS_USER  = KEYS['posterous']['username']
  POSTEROUS_PASS  = KEYS['posterous']['password']
  POSTEROUS_TOKEN = KEYS['posterous']['api_token']
  REDISTOGO_URL   = KEYS['redistogo']['url']
end

configure :production do
  CALLBACK_URL    = "http://luuunch.herokuapp.com/oauth/callback"
  CLIENT_ID       = ENV['INSTAGRAM_CLIENT_ID']    
  CLIENT_SECRET   = ENV['INSTAGRAM_CLIENT_SECRET'] 
  POSTEROUS_USER  = ENV['POSTEROUS_USER']
  POSTEROUS_PASS  = ENV['POSTEROUS_PASS']
  POSTEROUS_TOKEN = ENV['POSTEROUS_TOKEN']
  REDISTOGO_URL   = ENV['REDISTOGO_URL']
end

redis_uri = URI.parse(REDISTOGO_URL)
REDIS = Redis.new(:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password)

Instagram.configure do |config|
  config.client_id     = CLIENT_ID
  config.client_secret = CLIENT_SECRET
end


# Basic feed
get "/" do
  response = Instagram.tag_recent_media('luuunch')
  @photos = InstagramParser.parse(response.data)
  @photos.each do |photo| 
    log( {photo[:id] => photo[:title]} )
    settings.cache.add(photo[:id], photo)
  end
  erb :index
end

get '/ping' do 
  "ok"
end

# webhook callback url - respond back with 'hub.challenge'
get '/webhook' do
  log(params)
  params['hub.challenge']
end

post '/webhook' do
  if valid_webhook?(request)
    response = Instagram.tag_recent_media('luuunch')
  
    # parse
    photos   = InstagramParser.parse(response.data)
    
    # filter
    processed, unprocessed = photos.partition {|photo| settings.cache.get(photo[:id]) }
    
    # process
    unprocessed.each do |photo|
      tumblr_post = TumblrPublisher.publish(photo) 
      # record finish processing
      settings.cache.set(photo[:id], photo)
      log("==== Processed #{photo[:id]} #{photo[:title]}")
    end
  end
  ""
end




def valid_webhook?(request)
  content = request.body.read
  reply = JSON.parse(content)
  reply.any? {|e| e['object_id'] == 'luuunch' }
end

def log(msg)
  p msg
end