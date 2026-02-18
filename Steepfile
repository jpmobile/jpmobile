D = Steep::Diagnostic

target :lib do
  signature 'sig'

  # Ignore Rails/ActionView/ActionMailer/ActionController dependent signatures
  # These require Rails RBS definitions which are not included
  ignore_signature 'sig/jpmobile/mailer.rbs'
  ignore_signature 'sig/jpmobile/resolver.rbs'
  ignore_signature 'sig/jpmobile/path_set.rbs'
  ignore_signature 'sig/jpmobile/template_details.rbs'
  ignore_signature 'sig/jpmobile/view_selector.rbs'
  ignore_signature 'sig/jpmobile/trans_sid.rbs'
  ignore_signature 'sig/jpmobile/mail.rbs'
  ignore_signature 'sig/jpmobile/sinatra.rbs'
  ignore_signature 'sig/jpmobile/rails.rbs'
  ignore_signature 'sig/jpmobile/fallback_view_selector.rbs'
  ignore_signature 'sig/jpmobile/hook_action_view.rbs'
  ignore_signature 'sig/jpmobile/hook_template_details_requested.rbs'
  ignore_signature 'sig/jpmobile/lookup_context.rbs'
  ignore_signature 'sig/jpmobile/docomo_guid.rbs'
  ignore_signature 'sig/jpmobile/rack/mobile_carrier.rbs'
  ignore_signature 'sig/jpmobile/rack/filter.rbs'
  ignore_signature 'sig/jpmobile/rack/params_filter.rbs'
  ignore_signature 'sig/jpmobile/request_with_mobile.rbs'
  ignore_signature 'sig/jpmobile/filter.rbs'
  ignore_signature 'sig/jpmobile/helpers.rbs'
  ignore_signature 'sig/jpmobile/method_less_action_support.rbs'
  ignore_signature 'sig/jpmobile/email.rbs'
  ignore_signature 'sig/jpmobile/hook_test_request.rbs'

  # Check core mobile classes (non-Rails dependent code)
  check 'lib/jpmobile/mobile'
  check 'lib/jpmobile/position.rb'
  check 'lib/jpmobile/configuration.rb'
  check 'lib/jpmobile/util.rb'
  check 'lib/jpmobile/emoticon.rb'
  check 'lib/jpmobile/encoding.rb'
  check 'lib/jpmobile/datum_conv.rb'

  # Standard libraries used in jpmobile
  library 'singleton'
  library 'ipaddr'

  # Use lenient mode for initial setup to avoid overwhelming errors
  configure_code_diagnostics(D::Ruby.lenient)
end
