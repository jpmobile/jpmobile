module Jpmobile
  class Configuration
    include Singleton

    attr_accessor :form_accept_charset_conversion
    attr_accessor :smart_phone_emoticon_compatibility
    attr_accessor :fallback_view_selector

    def initialize
      @form_accept_charset_conversion     = false
      @smart_phone_emoticon_compatibility = false
      @fallback_view_selector             = false
    end

    def mobile_filter
      ::Jpmobile::Rack.mount_middlewares
    end
  end
end
