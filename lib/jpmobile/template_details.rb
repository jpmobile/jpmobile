module Jpmobile
  class TemplateDetails < ActionView::TemplateDetails
    def initialize(locale, handler, format, variant, mobile)
      @mobile = mobile

      super(locale, handler, format, variant)
    end

    def matches?(requested)
      requested.formats_idx[@format] &&
        requested.locale_idx[@locale] &&
        requested.variants_idx[@variant] &&
        requested.handlers_idx[@handler] &&
        requested.mobile_idx[@mobile]
    end

    def sort_key_for(requested)
      [
        requested.formats_idx[@format],
        requested.locale_idx[@locale],
        requested.variants_idx[@variant],
        requested.mobile_idx[@mobile],
        requested.handlers_idx[@handler],
      ]
    end
  end
end
