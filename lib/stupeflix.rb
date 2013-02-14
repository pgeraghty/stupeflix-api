require 'stupeflix/version'
require 'httparty'

class Stupeflix
  include HTTParty
  base_uri 'services.stupeflix.com'

  def initialize key, secret, id_prefix
    @key, @secret, @prefix = key, secret, id_prefix
    self.class.default_params AccessKey: key
  end

  def req method, body, mime, t, url
    md5hex, md5base64 = md5(body) rescue [nil, nil] # md5hex can be compared to etag in response for verification
    [{ Date: t, Signature: sign([method, md5base64, mime, t, url, nil]*"\n") },
     body ? { 'Content-MD5' => md5base64.to_s, 'Content-Length' => body.length.to_s, 'Content-Type' => mime } : nil]
  end

  def put_definition d, id=Time.now.to_i
    params, headers = req('PUT', d, 'text/xml', Time.now.to_i, url = "#{url id}/definition/")
    self.class.put url, query: params, headers: headers, body: d
  end

  def post_profiles profiles, id=Time.now.to_i
    params, headers = req('POST', body = "ProfilesXML=#{CGI::escape profiles}",
                          'application/x-www-form-urlencoded', Time.now.to_i, url = "#{url id}/")
    self.class.post url, query: params, headers: headers, body: body
  end

  def status id=Time.now.to_i
    params, headers = req('GET', nil, nil, Time.now.to_i, url = "#{url id}/status/")
    r = self.class.get url, query: params #, format: :json
    r.parsed_response rescue r
  end

  def url id
    "/stupeflix-1.0/#{@prefix}#{id}"
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
