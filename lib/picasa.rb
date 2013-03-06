require 'net/http'

module Picasa
  extend PicasaAuth

  def self.albums token
    xml_data = picasa_get "/data/feed/api/user/default?kind=album", token
    doc = Nokogiri::XML(xml_data).remove_namespaces!
    doc.xpath('//entry').map do |album|
      {
        :id => album.xpath('id')[1].text,
        :title => album.xpath('title').text,
        :thumbnail => album.xpath('group').at_xpath('thumbnail')["url"]
      }
    end
  end

  def self.photos token, id
    xml_data = picasa_get "/data/feed/api/user/default/albumid/#{id}?", token
    doc = Nokogiri::XML(xml_data).remove_namespaces!
    {
      :id => id,
      :title => doc.xpath('//feed/title').text,
      :photos => doc.xpath('//entry').map do |photo|
        {
          :id => photo.xpath('id')[1].text,
          :title => photo.xpath('title').text,
          :thumbnail => photo.xpath('group').xpath('thumbnail')[1]["url"],
          :url => photo.at_xpath('content')["src"]
        }
      end
    }
  end

  def self.comments token, album_id, photo_id
    xml_data = picasa_get "/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}?kind=comment", token
    doc = Nokogiri::XML(xml_data).remove_namespaces!
    {
      :id => photo_id,
      :album_id => doc.xpath('//albumid').text,
      :url => doc.xpath('//group').at_xpath('content')["url"],
      :comments => doc.xpath('//entry').map do |photo|
        {
          :content => photo.xpath('content').text,
          :author => photo.xpath('title').text
        }
      end
    }
  end

  def self.add_comment token, album_id, photo_id, comment
    add_comment_xml = <<EOF
        <entry xmlns='http://www.w3.org/2005/Atom'>
          <content>#{comment}</content>
          <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/photos/2007#comment"/>
      </entry>
EOF
    url = URI("http://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}/photoid/#{photo_id}")
    req = Net::HTTP::Post.new(url.path)
    req.add_field("Authorization", "AuthSub token=\"#{token[:access_token]}\"")
    req.content_type = 'application/atom+xml'
    req.body = add_comment_xml
    res = Net::HTTP.new(url.hostname, url.port)
    responce = res.request(req)
    doc = Nokogiri::XML(responce.body).remove_namespaces!
    {
      :content => doc.xpath('//content').text,
      :author => doc.xpath('//title').text
    }
  end

  def self.picasa_get url, token
    uri = URI.parse("http://picasaweb.google.com#{url}&access_token=#{token[:access_token]}")
    responce = Net::HTTP.get_response(uri)
    if responce.code == '403'
      refresh_token token
      return picasa_get url, token
    end
    responce.body
  end
end