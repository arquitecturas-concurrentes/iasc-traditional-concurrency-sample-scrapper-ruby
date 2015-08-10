require 'net/http'
require 'net/https'
require 'uri'
#require 'always_verify_ssl_certificates'
require_relative 'get_cacert'

class String
  def humanize_string
    self.sub(/^(.)/) { $1.capitalize }
  end
end

class Symbol
  def humanize
    self.to_s.humanize_string.to_sym
  end
end

class Request

  def make_request(uri, params = {})
    parsed_uri = URI.parse(uri)

    if parsed_uri.scheme == "https"
      return _build_https_request(parsed_uri, params)
    end

    _build_http_request(parsed_uri, params)
  end

  def send_generic_request(method, uri, params={}, headers={})
    http, parsed_uri = make_request(uri, params)
    selector = Kernel.const_get "Net::HTTP::#{method.humanize}"
    req = selector.send(:new, parsed_uri)
    self.send_request(http, req)
  end

  def get(uri, headers={}, params={})
    self.send_generic_request __method__, uri, params, headers
  end

  def post(uri, params={})
    http, parsed_uri = make_request(uri, params)
    req = Net::HTTP::Post.new(parsed_uri)
    unless params.nil?
      req.set_form_data(params)
    end
    self.send_request(http, req)
  end

  def put(uri, params={})
    self.send_generic_request __method__, uri, params
  end

  def delete(uri, params={})
    self.send_generic_request __method__, uri, params
  end

  def send_request(http, req, headers={})
    req.initialize_http_header(headers)
    http.request(req)
  end

  private

  def _build_https_request(parsed_uri, params)
    http= Net::HTTP.new(parsed_uri.host, parsed_uri.port)
    pem_path = File.dirname(__FILE__) + '/certs/cacert.pem'
    unless File.exist? pem_path
      CacertExtractor.new.get_cacert
    end
    pem = File.read(pem_path)
    http.use_ssl = true
    http.cert = OpenSSL::X509::Certificate.new(pem)
    public_key = "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAoxi2V0bSKqAqUtoQHxWkOPnErCS541r6/MOSHmKOd6VSNHoBbnas\nZRQSDUTbffB6C++DbmBCOHmvzYORD0ZWYgyMcgbYJD48Z2fe0nm+WMYN5u8DPnTP\nvf8b/rJBxGF0dsaoFAWlB81tTnKFCxAbCSgfmQt+Vd4qupGZ5gGu9uoKlaPjmYuA\nIxIjUMcu3dov7PQ+PZIvdkM0fiz8YIl8zo+iWWyI2s6/XLoZJ4bYs2YJHZDf6biU\nsZhs8xqh/F6qlcRt3Ta25KMa0TB9zE3HHmqA/EJHFubWFRCrQqpboB0+nwCbmZUl\nhaxA79FRvYtORvFAoncoFD4tq3rGXcUQQwIDAQAB\n-----END RSA PUBLIC KEY-----\n"
    http.key = OpenSSL::PKey::RSA.new(public_key)

    return http, parsed_uri
  end

  def _build_http_request(parsed_uri, params)
    http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
    return http, parsed_uri
  end

end