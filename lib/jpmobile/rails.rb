ActiveSupport.on_load(:action_controller) do
  require 'jpmobile/docomo_guid'
  require 'jpmobile/filter'
  require 'jpmobile/helpers'
  require 'jpmobile/hook_action_view'
  require 'jpmobile/trans_sid'
  require 'jpmobile/hook_test_request'
  ActionDispatch::Request.send :prepend, Jpmobile::Encoding
  ActionDispatch::Request.send :include, Jpmobile::RequestWithMobile
  ActionController::Base.send :prepend, Jpmobile::FallbackViewSelector
  ActionController::Base.send :prepend, Jpmobile::TransSidRedirecting
end

ActiveSupport.on_load(:after_initialize) do
  case Rails.application.config.session_store.to_s
  when 'ActionDispatch::Session::MemCacheStore'
    require 'jpmobile/session/mem_cache_store'
    ActionDispatch::Session::MemCacheStore.send :prepend, Jpmobile::ParamsOverCookie
  when 'ActionDispatch::Session::ActiveRecordStore'
    require 'jpmobile/session/active_record_store'
    ActionDispatch::Session::AbstractStore.send :prepend, Jpmobile::ParamsOverCookie
  else
    Rails.application.config.jpmobile.mount_session_store
  end
end

ActiveSupport.on_load(:before_configuration) do
  # MobileCarrierのみデフォルトで有効
  config.middleware.insert_after ActionDispatch::Flash, ::Jpmobile::MobileCarrier

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
