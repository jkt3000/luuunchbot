namespace :instagram do
  
  desc "setup webhook notification for instagram"
  task :create_webhook do
    require 'httparty'

    url    = "https://api.instagram.com/v1/subscriptions/"
    params = {
      'client_id'     => ENV['INSTAGRAM_CLIENT_ID'],
      'client_secret' => ENV['INSTAGRAM_CLIENT_SECRET'],
      'object'        => 'tag',
      'object_id'     => ENV['TAG'],
      'aspect'        => 'media',
      'callback_url'  => "http://luuunch.herokuapp.com/webhook"
    }
    response = HTTParty.post(url, params)
    p response
  end
end