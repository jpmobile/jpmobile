# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'rspec'
require 'jpmobile'
require 'jpmobile/rack'
require 'nkf'

begin
  require File.dirname(__FILE__)+'/../vendor/jpmobile-ipaddresses/lib/jpmobile-ipaddresses'
rescue LoadError
  puts "IP Address test requires jpmobile-ipaddresses module"
end
begin
  require File.dirname(__FILE__)+'/../vendor/jpmobile-terminfo/lib/jpmobile-terminfo'
rescue LoadError
  puts "Terminal display information test requires jpmobile-terminfo module"
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.color = true
end

class UnitApplication
  def initialize(body = nil)
    @body = Jpmobile::Util.utf8(body || "Body")
  end

  def call(env)
    Rack::Response.new(@body, 200, env).finish
  end
end

class ParamsApplication
  def initialize(app, form, query)
    @app   = app
    @form  = form
    @query = query
  end

  def call(env)
    env['rack.request.form_hash']  = @form
    env['rack.request.query_hash'] = @query

    @app.call(env)
  end
end

class RenderParamApp
  def call(env)
    request = Rack::Request.new(env)
    q = Jpmobile::Util.utf8(request.params['q'])

    [200, env, q]
  end
end

module Jpmobile::RackHelper
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
  include Jpmobile::Util

  def response_body(res)
    body = case res
           when Array
             res[2].body
           when String
             res.body
           else
             res.body
           end

    case body
    when Array
      body.first
    when String
      body
    else
      body
    end
  end
end
