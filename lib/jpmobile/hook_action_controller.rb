# -*- coding: utf-8 -*-
module AbstractController
  module ViewPaths
    def lookup_context_with_jpmobile
      jpmobile_context = lookup_context_without_jpmobile
      jpmobile_context.view_paths.controller = self

      jpmobile_context
    end

    alias_method_chain :lookup_context, :jpmobile
  end
end

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

# パラメータのUTF-8化
module Rack
  module Utils
    # UTF-8 で match させるようにする
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
  end
end
ActionController::Request.send :include, Jpmobile::Encoding
