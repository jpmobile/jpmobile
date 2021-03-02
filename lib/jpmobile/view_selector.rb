module Jpmobile
  module ViewSelector
    def self.included(base)
      base.class_eval do
        before_action :register_mobile

        self._view_paths = self._view_paths.dup
        self.view_paths.unshift(*self.view_paths.map {|resolver| Jpmobile::Resolver.new(resolver.to_path) })
      end
    end

    def register_mobile
      if request.mobile
        # register mobile
        self.lookup_context.mobile = request.mobile.variants
      end
    end

    def disable_mobile_view!
      self.lookup_context.mobile = []
    end

    private :register_mobile, :disable_mobile_view!
  end
  Rails::Application::Configuration.include Jpmobile::Configuration::RailsConfiguration
end
