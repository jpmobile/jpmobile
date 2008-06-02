unless Spec.const_defined?(:Rails)
  dir = File.dirname(__FILE__)

  # jpmobileの読み込み
  require 'rubygems'
  require 'action_controller'
  require 'initializer'
  require dir+'/../lib/jpmobile'

  # set (dummy) RAILS_ROOT
  RAILS_ROOT=dir+"/.."

  # load RSpec on Rails
  rspec_base = dir + '/../vendor/plugins/rspec-rails/lib'
  $LOAD_PATH.unshift rspec_base
  Dependencies.load_paths.unshift rspec_base
  Dependencies.load_once_paths.unshift rspec_base

  # application.rb を先に読ませる
  $LOAD_PATH.unshift "#{dir}/../spec_resources/controllers" 
  require 'application'

  # setup resources
  Dir[File.expand_path("#{dir}/../spec_resources/**/*.rb")].sort.each do |file|
    require file
  end

  # setup routes
  ActionController::Routing::Routes.draw do |map|
    map.connect ':controller/:action/:id.:format'
    map.connect ':controller/:action/:id'
  end

  require 'spec/rails'
end
