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
