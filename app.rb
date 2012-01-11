require 'rubygems'
require 'sinatra'

configure :production do
  # Configure stuff here you'll want to
  # only be run at Heroku at boot

  # TIP:  You can get you database information
  #       from ENV['DATABASE_URI'] (see /env route below)
end

# Quick test
get '/' do
  "<style>html {font-family:arial}</style>
  <h1>Congrats!</h1>
   <p>You're running a Sinatra application on Heroku!</p>"
end
