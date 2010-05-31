# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'spec'
require 'spec/fixture' # gem rspec-fixture
require 'jpmobile'
require 'jpmobile/rack'
require 'pp' # for debug

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end

class UnitApplication
  def call(env)
    env
  end
end
