require 'rack/test'

include Rack::Test::Methods
def app
  Rails::Rack::Metal.new(Hello)
end

describe Hello do
  it "" do
    get "/hello", {"name" => "Yamada"}
    last_response.ok?.should be_true
    last_response.body.to_s.should == "Hello, Yamada!"
  end
end
