Rails.application.config.jpmobile.mobile_filter
Rails.application.config.jpmobile.form_accept_charset_conversion = true

Rails.application.config.jpmobile.session_store do
  # # MemCacheStore
  # require 'jpmobile/session/mem_cache_store'
  # ActionDispatch::Session::MemCacheStore.send :include, Jpmobile::TransSid::ParamsOverCookie

  # # ActiveRecordStore
  # require 'jpmobile/session/active_record_store'
  # ActionDispatch::Session::AbstractStore.send :include, Jpmobile::TransSid::ParamsOverCookie
end
