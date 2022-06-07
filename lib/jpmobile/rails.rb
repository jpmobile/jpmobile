ActiveSupport.on_load(:action_controller) do
  require 'jpmobile/docomo_guid'
  require 'jpmobile/filter'
  require 'jpmobile/helpers'
  require 'jpmobile/implicit_render'
  require 'jpmobile/trans_sid'
  require 'jpmobile/hook_test_request'
  ActionDispatch::Request.prepend Jpmobile::Encoding
  ActionDispatch::Request.include Jpmobile::RequestWithMobile
  ActionController::Base.prepend Jpmobile::FallbackViewSelector
  ActionController::Base.prepend Jpmobile::TransSidRedirecting
end

ActiveSupport.on_load(:action_view) do
  require 'jpmobile/hook_action_view'
  require 'jpmobile/hook_template_details_requested'

  self.prepend Jpmobile::HtmlOptionsWithAcceptCharset
  ActionView::TemplateDetails::Requested.prepend Jpmobile::HookTemplateDetailsRequested
end

ActiveSupport.on_load(:after_initialize) do
  case Rails.application.config.session_store.to_s
  when 'ActionDispatch::Session::MemCacheStore'
    require 'jpmobile/session/mem_cache_store'
    ActionDispatch::Session::MemCacheStore.prepend Jpmobile::ParamsOverCookie
  when 'ActionDispatch::Session::ActiveRecordStore'
    require 'jpmobile/session/active_record_store'
    ActionDispatch::Session::AbstractStore.prepend Jpmobile::ParamsOverCookie
  else
    Rails.application.config.jpmobile.mount_session_store
  end
end

ActiveSupport.on_load(:before_configuration) do
  # MobileCarrierのみデフォルトで有効
  config.middleware.insert_after ActionDispatch::Flash, ::Jpmobile::MobileCarrier

  Rails::Application::Configuration.include Jpmobile::Configuration::RailsConfiguration
end
