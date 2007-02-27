require 'test/unit'
require 'rubygems'
require 'action_controller'

require File.dirname(__FILE__)+'/../lib/jpmobile'

class FakeCgi < CGI
  attr_accessor :stdinput, :stdoutput, :env_table
  def initialize(user_agent, env={})
    self.env_table = {"HTTP_USER_AGENT"=>user_agent,"QUERY_STRING"=>""}.update(env)
    super()
  end
end

def request_with_ua(user_agent, env={})
  fake_cgi = FakeCgi.new(user_agent, env)
  ActionController::CgiRequest.new(fake_cgi)
end
