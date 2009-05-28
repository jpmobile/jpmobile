require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'rack'

RAILS_ENV = "test"
require File.dirname(__FILE__)+'/../../lib/jpmobile'

# ActionPackのTestのためのrequire
action_pack_full_path = Gem.cache.search('actionpack').sort_by { |g| g.version.version }.last
require File.join(action_pack_full_path.full_gem_path,'test/abstract_unit')

class FakeCgi < CGI
  attr_accessor :stdinput, :stdoutput, :env_table
  def initialize(user_agent, env={})
    self.env_table = {"HTTP_USER_AGENT"=>user_agent,"QUERY_STRING"=>""}.update(env)
    super()
  end
end

def request_with_ua(user_agent, env={})
  fake_cgi = FakeCgi.new(user_agent, env)
  [
    Rack::Request.new(
      Rack::MockRequest.env_for('http://www.example.jp', fake_cgi.env_table)
    ).extend(Jpmobile::RequestWithMobile)
  ]
end

## add helper methods to rails testing framework
module ActionController
  class TestRequest < Request
    attr_accessor :user_agent
  end
end

module Jpmobile::TestHelper
  def user_agent(str)
    @request.user_agent = str
  end
  def init(c)
    @controller = c.new
    @controller.logger = Logger.new(nil)
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.host = "www.example.jp"
    @request.session.session_id = "mysessionid"
  end
end
Test::Unit::TestCase.class_eval{ include Jpmobile::TestHelper }
