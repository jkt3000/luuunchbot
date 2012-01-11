require 'rubygems'
require 'sinatra'
require 'yaml'
require 'instagram'
require 'json'


use Rack::Session::Cookie

enable :logging

configure :development do
  keyfile = File.join(File.dirname(__FILE__), 'keys.yml')
  KEYS = YAML.load(File.read(keyfile)) if File.exists?(keyfile)
  CALLBACK_URL  = "http://localhost:4567/oauth/callback"
  CLIENT_ID     = KEYS['client_id']
  CLIENT_SECRET = KEYS['client_secret']
end

configure :production do
  CALLBACK_URL  = "http://luuunch.herokuapp.com/oauth/callback"
  CLIENT_ID     = ENV['INSTAGRAM_CLIENT_ID']    
  CLIENT_SECRET = ENV['INSTAGRAM_CLIENT_SECRET'] 
  # Configure stuff here you'll want to
  # only be run at Heroku at boot

  # TIP:  You can get you database information
  #       from ENV['DATABASE_URI'] (see /env route below)
end

Instagram.configure do |config|
  config.client_id     = CLIENT_ID
  config.client_secret = CLIENT_SECRET
end

# Basic feed
get "/" do
  response = Instagram.tag_recent_media('luuunch')
  @photos = response.data
  erb :index
end

# webhook callback url - respond back with 'hub.challenge'
get '/webhook' do
  # params: 'hub.mode', 'hub.challenge', 'hub.verify_token'
  p 'GET /webhook'
  p params
end

post '/webhook' do
  p params
  body = request.body.read
  x = JSON.parse(body)
  p "json is #{x.inspect}"
end




# oauth stuff
get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user.username}'s recent photos</h1>"
  for media_item in client.user_recent_media
    p media_item
    break
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  erb html
end

