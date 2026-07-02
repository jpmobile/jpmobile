# spec/spec_helper.rb
require 'rubygems'
require 'rack/test'
require 'rspec'
if ENV['COVERAGE']
  require_relative 'support/coverage'
  JpmobileCoverage.start('rack')
end
require 'jpmobile'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.color = true
end

class UnitApplication
  def initialize(body = nil)
    @body = body || 'Body'
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
    @request.host = 'www.example.jp'
    @request.session.session_id = 'mysessionid'
  end

  def response_body(res)
    body = case res
           when Array
             res[2]
           else
             res.body
           end

    case body
    when Array
      body.first
    else
      body
    end
  end
end
