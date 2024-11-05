module Jpmobile
  module ViewSelector
    extend ActiveSupport::Concern

    included do
      before_action :register_mobile

      self.view_paths = Jpmobile::PathSet.new(self.view_paths.paths.map(&:path))
    end

    private

    def register_mobile
      if request.mobile
        # register mobile
        self.lookup_context.mobile = request.mobile.variants
      end
    end

    def disable_mobile_view!
      self.lookup_context.mobile = []
    end
  end
  Rails::Application::Configuration.include Jpmobile::Configuration::RailsConfiguration
end
