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
  def initialize(body = nil)
    @body = body || "Body"
  end

  def call(env, mobile = nil)
    [200, env, @body]
  end
end

class ParamsApplication
  def initialize(app, form, query)
    @app   = app
    @form  = form
    @query = query
  end

  def call(env, mobile = nil)
    env['rack.request.form_hash']  = @form
    env['rack.request.query_hash'] = @query

    @app.call(env)
  end
end

class RenderParamApp
  def call(env, mobile = nil)
    request = Rack::Request.new(env)

    [200, env, request.params['q']]
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
  def sjis(ascii_8bit)
    if ascii_8bit.respond_to?(:force_encoding)
      ascii_8bit.force_encoding("Shift_JIS")
    end
    ascii_8bit
  end
  def utf8(ascii_8bit)
    if ascii_8bit.respond_to?(:force_encoding)
      ascii_8bit.force_encoding("utf-8")
    end
    ascii_8bit
  end
  def to_sjis(utf8)
    if utf8.respond_to?(:encode)
      utf8.encode("Shift_JIS")
    else
      NKF.nkf("-sWx", utf8)
    end
  end
end
