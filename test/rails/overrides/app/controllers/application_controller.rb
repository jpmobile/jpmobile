# require 'rubygems'
# require 'action_controller'

class ApplicationController < ActionController::Base
  include Jpmobile::ViewSelector
end
