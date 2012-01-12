namespace :ping do
  desc "Ping self"
  task :self do
    require 'httparty'
    response = HTTParty.get('http://luuunch.herokuapp.com/ping')
    p response
  end
end