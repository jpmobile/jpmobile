# -*- coding: utf-8 -*-
require 'jpmobile/lookup_context'

module ActionController
  class Base
    include Jpmobile::Helpers
    before_filter :gettext_force_ja_for_mobile
    # gettextが組み込まれている場合、携帯電話からのアクセスをjaロケールに強制する。
    def gettext_force_ja_for_mobile
      if Object.const_defined?(:GetText) and request.mobile?
        begin
          ::GetText.locale = 'ja'
        rescue NameError
        end
      end
    end
  end
end

module ActionController
  module Renderers
    def render_to_body_with_jpmobile(options)
      if Jpmobile.config.fallback_view_selector and
          lookup_context.mobile.present? and !lookup_context.mobile.empty?
        begin
          expected_view_file = lookup_context.find_template(options[:template], options[:prefixes])

          _candidates = lookup_context.mobile.map { |variant|
            target_templat = options[:template] + '_' + variant
            expected_view_file.virtual_path.match(target_templat)
          }.compact

          if _candidates.empty?
            lookup_context.mobile = []
          end
        rescue ActionView::MissingTemplate
        end
      end

      render_to_body_without_jpmobile(options)
    end

    alias_method_chain :render_to_body, :jpmobile
  end
end
