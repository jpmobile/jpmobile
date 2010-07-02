# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'rspec'
require 'jpmobile'
require 'jpmobile/rack'
require 'pp' # for debug

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

class UnitApplication
  def initialize(body = nil)
    @body = body || "Body"
    if @body.respond_to?(:force_encoding)
      @body.force_encoding("UTF-8")
    end
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
    q = request.params['q']
    if q.respond_to?(:force_encoding)
      q.force_encoding("UTF-8")
    end

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
