module PosterousPublisher
  require 'posterous'
  
  def self.publish(photo)
    Posterous.config = {
      'username'  => POSTEROUS_USER,
      'password'  => POSTEROUS_PASS,
      'api_token' => POSTEROUS_TOKEN
    }

    settings = {
      :title => photo[:title],
      :body  => "#{photo[:large_url]}\n <p>from #{photo[:username]}</p>",
      :tags  => photo[:tags]
    }
    
    @site = Posterous::Site.primary 
    @post = @site.posts.create(settings)
  rescue => e
    p "Error creating post #{e}"
    nil
  end
  
  
end