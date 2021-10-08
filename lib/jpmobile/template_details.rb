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
        requested.handlers_idx[@handler],
        requested.mobile_idx[@mobile],
      ]
    end

    class Requested < ActionView::TemplateDetails::Requested
      attr_reader :mobile, :mobile_idx

      def initialize(locale:, handlers:, formats:, variants:, mobile:)
        super(locale: locale, handlers: handlers, formats: formats, variants: variants)

        @mobile = mobile.map(&:to_sym)
        @mobile_idx = build_idx_hash(mobile)
      end
    end
  end
end
