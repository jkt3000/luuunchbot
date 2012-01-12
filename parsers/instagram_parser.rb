module InstagramParser
  
# return back array of hashes  
# {
#   :caption
#   :created_at
#   :small_url
#   :medium_url
#   :large_url
#   :link_url
#   :tags
#   :username
# }
  
  def self.parse(data)
    photos = data.map do |entry|
      photo = {
        :id         => entry.id,
        :title      => entry.caption.text,
        :created_at => Time.at(entry.created_time.to_i),
        :link_url   => entry.link,
        :small_url  => entry.images.thumbnail.url,
        :medium_url => entry.images.low_resolution.url,
        :large_url  => entry.images.standard_resolution.url,
        :tags       => entry.tags,
        :username   => entry.caption.from.username
      }
      photo[:tags].each {|tag| photo[:title].gsub!(/\##{tag}/,"") }
      photo[:title].strip!
      photo[:tags].reject! {|t| t == 'luuunch' }
      photo
    end
  end
  
end