require_relative 'support/fake_example'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, 'www.example.com:80').to_rack(FakeExampleCom)
  end
end