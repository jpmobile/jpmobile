require 'rubygems'
require 'sinatra'
require 'jpmobile'
require 'jpmobile/rack'
require 'singleton'
require 'pp'

require 'jpmobile'
require 'jpmobile/rack'

class SinatraTestHelper
  include Singleton
  attr_accessor :last_app
end

class Guestbook < Sinatra::Base
  use Jpmobile::Rack::MobileCarrier
  use Jpmobile::Rack::ParamsFilter
  use Jpmobile::Rack::Filter

  def call(env)
    _dup = dup
    SinatraTestHelper.instance.last_app = _dup
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
end

Guestbook.run
