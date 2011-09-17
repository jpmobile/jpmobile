require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), '../../lib/jpmobile')
require 'jpmobile/rack'
require 'singleton'
require 'pp'

require 'jpmobile/sinatra'

class SinatraTestHelper
  include Singleton
  attr_accessor :last_app
end

class Guestbook < Jpmobile::Sinatra::Base
  use Jpmobile::Rack::MobileCarrier
  use Jpmobile::Rack::ParamsFilter
  use Jpmobile::Rack::Filter

  def call(env)
    _dup = dup
    ::SinatraTestHelper.instance.last_app = _dup
    _dup.call!(env)
  end

  def assigns(sym)
    instance_variable_get("@#{sym}")
  end

  get '/' do
    @g = params[:g]
  end

  post '/' do
    @p = params[:p]
  end

  get '/top' do
    erb :index
  end
end
