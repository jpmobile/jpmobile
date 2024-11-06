require 'jpmobile/lookup_context'

module Jpmobile
  module FallbackViewSelector
    def _render_template(options)
      if Jpmobile.config.fallback_view_selector &&
         lookup_context.mobile.present? && !lookup_context.mobile.empty?
        begin
          expected_view_file = lookup_context.find_template(options[:template], options[:prefixes])

          _candidates = lookup_context.mobile.filter_map do |variant|
            target_template = options[:template] + '_' + variant
            expected_view_file.virtual_path.match(target_template)
          end

          if _candidates.empty?
            lookup_context.mobile = []
          end
        rescue ActionView::MissingTemplate
        end
      end

      super
    end
  end
end
