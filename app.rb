require 'rubygems'
require 'sinatra'
require 'yaml'
require 'instagram'

CALLBACK_URL = "http://luuunch.herokuapp.com/oauth/callback"


configure :production do
  # Configure stuff here you'll want to
  # only be run at Heroku at boot

  # TIP:  You can get you database information
  #       from ENV['DATABASE_URI'] (see /env route below)
end


enable :sessions


keyfile = File.join(File.dirname(__FILE__), 'keys.yml')
KEYS = YAML.load(File.read(keyfile)) if File.exists?(keyfile)

Instagram.configure do |config|
  config.client_id     = ENV['INSTAGRAM_CLIENT_ID']     || KEYS['client_id']
  config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET'] || KEYS['client_secret']
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

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
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end