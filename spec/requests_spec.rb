require 'webmock/rspec'
require 'spec_helper'
require_relative '../src/requestsrb'

describe 'Test example.com requests' do

  it 'make a simple GET' do
    response = Request.new.get('http://www.example.com/contributors')
    puts response
  end

  it 'make a simple POST' do
    response = Request.new.post('http://www.example.com/post')
    puts response
  end

  it 'make a simple PUT' do
    response = Request.new.put('http://www.example.com/put')
    puts response
  end

  it 'make a simple DELETE' do
    response = Request.new.delete('http://www.example.com/delete/post')
    puts response
  end

  it 'pass parameters to a POST' do
    parameters = {'key1' => 'value1', 'key2' => 'value2'}

    response = Request.new.post('http://www.example.com/post', params = parameters)
    puts response
  end


end

