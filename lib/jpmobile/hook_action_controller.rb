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
