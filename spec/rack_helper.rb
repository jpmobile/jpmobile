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
    [200, env, "Body"]
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
