require 'stupeflix/version'
require 'httparty'
require 'nokogiri'
require 'cgi'

module Stupeflix
  class Video
    include HTTParty
    base_uri 'services.stupeflix.com'

    def initialize id, key, secret
      @id, @key, @secret = id, key, secret
      self.class.default_params AccessKey: key
    end

    def req method, body, mime, t, url
      md5hex, md5base64 = md5(body) rescue [nil, nil] # md5hex can be compared to etag in response for verification
      [{ Date: t, Signature: sign([method, md5base64, mime, t, url, nil]*"\n") },
       body ? { 'Content-MD5' => md5base64.to_s, 'Content-Length' => body.length.to_s, 'Content-Type' => mime } : nil]
    end

    def definition= d
      params, headers = req('PUT', d, 'text/xml', Time.now.to_i, url = "#{self.url}/definition/")
      r = self.class.put url, query: params, headers: headers, body: d
      raise "Invalid response: #{r.response.code}" unless r.response.code.to_i == 200
    end

    # TODO make this an array or..?
    def profiles= profiles_xml
      params, headers = req('POST', body = "ProfilesXML=#{::CGI::escape profiles_xml}",
                            'application/x-www-form-urlencoded', Time.now.to_i, url = "#{self.url}/")
      r = self.class.post url, query: params, headers: headers, body: body
      raise "Invalid response: #{r.response.code}" unless r.response.code.to_i == 200
    end

    def status
      params, headers = req('GET', nil, nil, Time.now.to_i, url = "#{self.url}/status/")
      r = self.class.get url, query: params #, format: :json
      r.parsed_response rescue r
    end

    def url
      "/stupeflix-1.0/#{@id}" # user/resource
    end

    protected

    def sign str
      OpenSSL::HMAC.hexdigest OpenSSL::Digest::Digest.new('sha1'), @secret, str
    end

    def md5 body
      md5 = Digest::MD5.new().update body
      [md5.hexdigest, Base64.encode64(md5.digest).strip]
    end
  end

  class Definition < Nokogiri::XML::Builder
    EFFECTS = %w(kenburns flower rectangles none) # http://wiki.stupeflix.com/doku.php?id=effects
    FONTS = %w(arial arialbold arialroundedmtbold comicsansms couriernew landspeedrecord saddlebag timesnewroman verdana)
    DIRECTIONS = %w(left right up down)
    TRANSITIONS = %w(circle crossfade cube move over radial scan scans spiral strip swirl under waterdrop)
    TRANSITIONS_WITH_DIR = %w(cube move over scan spiral under)

    def initialize &block
      super({}, Nokogiri::XML::Document.new) do |x|
        x.movie(service: 'craftsman-1.0') {
          x.body {
            yield x if block_given?
          }
        }
      end
    end

    def add_slide url, caption, options={}
      options = { duration: 1 }.merge options
      add_transition
      stack(duration: options[:duration]) {
        add_image url
        add_text_overlay caption if caption.length > 0 rescue nil
      }
    end

    def add_map map
      overlay(right: '0.0', bottom: '0.0', width:'0.25') {
        effect(type: 'none') {
          image filename: map
          filter type: 'frame', color: '#FFFFFFFF', width: '0.02'
          # could also use <image type="map" center="38.6436469,0.0456876" zoom="11" markers="38.6436469,0.0456876" size="250x150" mapkey="GMAPS_API_KEY" maptype="map"/>
          # as documented here: http://wiki.stupeflix.com/doku.php?id=gmapsimage
        }
        animator type: 'slide-in', direction: 'up', duration:'1.0'
        animator type: 'slide-out', direction: 'down', 'margin-start' => '6.0'
      }
    end

    def add_image url, options={}
      effect({ type: EFFECTS.sample }.merge options) {
        image filename: url
      }
    end

    def add_text caption, options={}
      return unless caption.length > 0 rescue nil
      defaults = { type: 'zone', vector: 'true', align: 'left,bottom' }
      long_caption = caption.length > 30
      #defaults[:align] = 'center,top'
      defaults[:fontsize] = 30 unless long_caption # prevent auto-scale from filling screen with huge text
      text_(defaults.merge options) {
        text caption
        filter(type: 'distancemap', distanceWidth: 40.0)
        filter type: 'distancecolor', distanceWidth: 40.0, color: '#de7316',
               strokeColor: '#000000', strokeOpacity: 1.0, strokeWidth: 0.02,
               dropShadowColor: '#00000044', dropShadowOpacity: 1.0, dropShadowBlurWidth: '0.9',
               dropShadowPosition: '0.01,-0.01', outerGlowColor: '#ffffff44', outerGlowOpacity: 1.0, outerGlowBlurWidth: 0.7
      }
    end

    def add_text_overlay caption, options={}
      overlay {
        add_text caption, options
      }
    end

    def add_transition options={}
      defaults = { type: TRANSITIONS.sample }
      defaults[:direction] = DIRECTIONS.sample if TRANSITIONS_WITH_DIR.include? defaults[:type]
      transition defaults.merge(options)
    end
  end
end
