unless RSpec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)

  # jpmobileの読み込み
  require 'rubygems'
  require 'initializer'
  require dir + '/../lib/jpmobile'

  require 'rspec/rails'
end
