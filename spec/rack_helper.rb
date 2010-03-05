# spec/spec_helper.rb
require 'rack/test'
require 'jpmobile'
require 'jpmobile/rack'
require 'pp' # for debug

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end
