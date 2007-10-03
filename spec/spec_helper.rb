unless Spec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)

  # jpmobileの読み込み
  require 'rubygems'
  require 'action_controller'
  require dir+'/../lib/jpmobile'

  # set (dummy) RAILS_ROOT
  RAILS_ROOT=dir+"/.."

  # load RSpec on Rails
  rspec_base = dir + '/../vendor/plugins/rspec_on_rails/lib'
  $LOAD_PATH.unshift rspec_base
  Dependencies.load_paths.unshift rspec_base
  Dependencies.load_once_paths.unshift rspec_base

  # setup controllers
  controller_base = "#{dir}/../spec_resources/controllers"
  $LOAD_PATH.unshift controller_base
  Dependencies.load_paths.unshift controller_base
  Dependencies.load_once_paths.unshift controller_base

  require 'spec/rails'

end
