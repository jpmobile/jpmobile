# -*- coding: utf-8 -*-
ActiveSupport.on_load(:action_controller) do
  require 'jpmobile/docomo_guid'
  require 'jpmobile/filter'
  require 'jpmobile/helpers'
  require 'jpmobile/hook_action_controller'
  require 'jpmobile/hook_action_view'
  require 'jpmobile/trans_sid'
  require 'jpmobile/hook_test_request'
end
ActiveSupport.on_load(:action_dispatch) do
  require 'jpmobile/hook_action_dispatch'
end

ActiveSupport.on_load(:before_configuration) do
  # MobileCarrierのみデフォルトで有効
  config.middleware.insert_before ActionDispatch::ParamsParser, Jpmobile::Rack::MobileCarrier

  module Rails
    class Application
      class Configuration
        def jpmobile
          @jpmobile ||= ::Jpmobile.config
        end
      end
    end
  end
end

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
end
