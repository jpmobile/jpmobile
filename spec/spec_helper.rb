# -*- coding: utf-8 -*-
unless RSpec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)

  # jpmobileの読み込み
  require 'rubygems'
  require 'initializer'
  require dir+'/../lib/jpmobile'
  begin
    require dir+'/../vendor/jpmobile-ipaddresses/lib/jpmobile-ipaddresses'
  rescue LoadError
    puts "IP Address test requires jpmobile-ipaddresses module"
  end

  begin
    require dir+'/../vendor/jpmobile-terminfo/lib/jpmobile-terminfo'
  rescue LoadError
    puts "Terminal display information test requires jpmobile-terminfo module"
  end

  require 'rspec/rails'
end
