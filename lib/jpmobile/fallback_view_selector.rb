require 'jpmobile/lookup_context'

module Jpmobile
  module FallbackViewSelector
    def render_to_body(options)
      if Jpmobile.config.fallback_view_selector &&
         lookup_context.mobile.present? && !lookup_context.mobile.empty?
        begin
          expected_view_file = lookup_context.find_template(options[:template], options[:prefixes])

          _candidates = lookup_context.mobile.map {|variant|
            target_template = options[:template] + '_' + variant
            expected_view_file.virtual_path.match(target_template)
          }.compact

          if _candidates.empty?
            lookup_context.mobile = []
          end
        rescue ActionView::MissingTemplate
        end
      end

      super(options)
    end
  end
end
