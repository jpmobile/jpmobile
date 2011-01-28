# require 'rubygems'
# require 'action_controller'

class ApplicationController < ActionController::Base
  before_filter :register_mobile

  self._view_paths = self._view_paths.dup
  self.view_paths.unshift(Jpmobile::Resolver.new(File.join(Rails.root, "app/views")))

  def register_mobile
    if request.mobile
      # register mobile
      self.lookup_context.mobile = request.mobile.variants
    end
  end
end
