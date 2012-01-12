module TumblrPublisher  
  require 'tumblr'

  def self.login
    Tumblr::User.new(POSTEROUS_USER, POSTEROUS_PASS)
  end
  
  def self.publish(photo)
    user = login
    Tumblr.blog = 'luuunch'
    
    newtags = photo[:tags].dup
    newtags << photo[:username]
    params = {
      :caption => photo[:title],
      :type    => 'photo',
      :tags    => newtags.join(","),
      :source  => photo[:large_url],
      :'click-through-url' => photo[:link_url]
    }
    post = Tumblr::Post.create(user, params)
  rescue => e
    p "[ERROR] Unable to create tumblr post #{e}"
    nil
  end
  
end