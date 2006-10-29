require 'test/unit'
require 'rubygems'
require 'action_controller'

require 'init'

class FakeCgi
  def initialize(user_agent, env={})
    @env_table = {"HTTP_USER_AGENT"=>user_agent}.update(env)
  end
  def query_string
    @env_table["QUERY_STRING"] || ""
  end
  def params
    CGIMethods.parse_query_parameters(query_string)
  end
  attr_reader :env_table
end

def request_with_ua(user_agent, env={})
  fake_cgi = FakeCgi.new(user_agent, env)
  req = ActionController::CgiRequest.new(fake_cgi)
end
