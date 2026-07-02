ActiveSupport.on_load(:action_controller) do
  require 'jpmobile/method_less_action_support'
  ActionDispatch::Request.include Jpmobile::RequestWithMobile
  ActionController::Base.prepend Jpmobile::FallbackViewSelector

  if Rails.env.test?
    require 'jpmobile/hook_test_request'
  end
end

ActiveSupport.on_load(:action_view) do
  require 'jpmobile/hook_template_details_requested'

  ActionView::TemplateDetails::Requested.prepend Jpmobile::HookTemplateDetailsRequested
end

ActiveSupport.on_load(:before_configuration) do
  # MobileCarrierのみデフォルトで有効
  config.middleware.insert_after ActionDispatch::Flash, Jpmobile::MobileCarrier

  Rails::Application::Configuration.include Jpmobile::Configuration::RailsConfiguration
end
