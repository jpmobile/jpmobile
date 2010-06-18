# -*- coding: utf-8 -*-

require 'rubygems'
begin
  gem 'test-unit', '= 1.2.3'
rescue Gem::LoadError
end
require 'test/unit'
action_pack_version = ENV['RAILS_VERSION'] || '2.3.0'
gem 'actionpack', "~> #{action_pack_version}"
require 'action_controller'
require 'rack'

RAILS_ENV = "test"
require File.dirname(__FILE__)+'/../../lib/jpmobile'

# ActionPackのTestのためのrequire
action_pack_gem = Gem.cache.find_name('actionpack').find do |gem|
  gem.version.version >= action_pack_version
end
require File.join(action_pack_gem.full_gem_path,'test/abstract_unit')

class FakeApp
  def call(env, mobile)
    [200, env, ""]
  end
end

def request_with_ua(user_agent, env={})
  res = Rack::MockRequest.env_for('http://www.example.jp',
    {"HTTP_USER_AGENT" => user_agent}.update(env))
  res = Jpmobile::Rack::MobileCarrier.new(FakeApp.new).call(res)

  [
    Rack::Request.new(res[1]).extend(Jpmobile::RequestWithMobile)
  ]
end

module Jpmobile::TestHelper
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
      utf8.tosjis
    end
  end
end
Test::Unit::TestCase.class_eval{ include Jpmobile::TestHelper }
