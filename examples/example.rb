require 'stupeflix'

# Set a unique identifier e.g. 'user/resource_id'
id = "#{'abcdefghijk'.chars.to_a.shuffle.join}/slideshow#{Time.now.to_i}"

# Configure credentials
s = Stupeflix::Video.new id, YOUR_ACCESS_KEY, YOUR_SECRET_KEY

# To PUT a video definition
s.definition = Stupeflix::Definition.new do |xml|
  images = %w(qiwD B0-X hXBA rEpt 9w95 ILMo mO6A oUay st5s wExP 01Wb IouW zlCm).map { |i| 'http://gdurl.com/' + i }.shuffle[0...8]
  xml.stack(duration: 4) {
    xml.add_image images.pop
    xml.add_text 'Example', align: 'center,center'
  }
  images.each_with_index do |i,x|
    xml.add_slide i, "Slide #{x}", duration: 4
  end
end.doc.root.to_xml

# POST profiles to request videos be generated accordingly
s.profiles = Nokogiri::XML::Builder.new do |x|
  x.profiles {
    x.profile(name: '720p') {
      x.stupeflixStore
      x.youtube(login: YOUR_YOUTUBE_USER, password: YOUR_YOUTUBE_PASSWORD) {
        x.meta {
          x.title 'Stupeflix API Test'
          x.description 'A test of the Stupeflix Ruby API wrapper @ https://github.com/pgeraghty/stupeflix-api.'
          #x.tags tags
          x.channels 'Tech'
          x.acl 'unlisted'
        }
      }
    }
  }
end.doc.root.to_xml(save_with: 0).gsub('<stupeflixStore/>', '<stupeflixStore></stupeflixStore>')

# GET status of requested videos, loop until done
result = nil
while result.nil?
  status = s.status
  status = status.first['status'] rescue status
  result = if err = status['error'] rescue nil
    err
  elsif yt_id = status['available-1-url'].scan(/v=([^&]+)/i).flatten.first rescue nil
    "Complete: http://www.youtube.com/watch?v=#{yt_id}&hd=1"
  elsif (%w(queued generating generated uploading available).include? status['status'] rescue nil)
    p 'Processing...'; nil
  elsif (status.response.code.to_i != 200 rescue nil)
    "Error: #{status}"
  else
    "Unknown Error: #{status}"
  end
  break if result
  sleep 5 
end
p result
