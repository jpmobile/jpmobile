D = Steep::Diagnostic

target :lib do
  signature 'sig'

  # Ignore Rails/ActionView/ActionController dependent signatures
  # These require Rails RBS definitions which are not included
  ignore_signature 'sig/jpmobile/resolver.rbs'
  ignore_signature 'sig/jpmobile/path_set.rbs'
  ignore_signature 'sig/jpmobile/template_details.rbs'
  ignore_signature 'sig/jpmobile/view_selector.rbs'
  ignore_signature 'sig/jpmobile/sinatra.rbs'
  ignore_signature 'sig/jpmobile/rails.rbs'
  ignore_signature 'sig/jpmobile/fallback_view_selector.rbs'
  ignore_signature 'sig/jpmobile/hook_template_details_requested.rbs'
  ignore_signature 'sig/jpmobile/lookup_context.rbs'
  ignore_signature 'sig/jpmobile/rack/mobile_carrier.rbs'
  ignore_signature 'sig/jpmobile/request_with_mobile.rbs'
  ignore_signature 'sig/jpmobile/method_less_action_support.rbs'
  ignore_signature 'sig/jpmobile/hook_test_request.rbs'

  # Check core mobile classes (non-Rails dependent code)
  check 'lib/jpmobile/mobile'
  check 'lib/jpmobile/configuration.rb'

  # Standard libraries used in jpmobile
  library 'singleton'

  # Use lenient mode for initial setup to avoid overwhelming errors
  configure_code_diagnostics(D::Ruby.lenient)
end
