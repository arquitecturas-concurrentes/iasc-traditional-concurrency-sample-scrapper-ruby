require 'sinatra/base'

class FakeExampleCom < Sinatra::Base
  get '/contributors' do
    json_response 200, 'contributors.json'
  end

  post '/post' do
    'Post received'
  end

  put '/put' do
    'Put received'
  end

  delete '/delete/post' do
    'delete received'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end