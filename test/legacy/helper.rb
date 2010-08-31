# -*- coding: utf-8 -*-
require 'rubygems'
begin
  gem 'test-unit', '= 1.2.3'
rescue Gem::LoadError
end
require 'test/unit'
require File.dirname(__FILE__)+'/../../lib/jpmobile'
