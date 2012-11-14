# -*- coding: utf-8 -*-
module Jpmobile::Mobile
  module UnicodeEmoticon
    # Jpmobile::Rack::Filter を適用する
    def apply_filter?
      Jpmobile.config.smart_phone_emoticon_compatibility
    end

    # Jpmobile::Rack::ParamsFilter を適用する
    def apply_params_filter?
      Jpmobile.config.smart_phone_emoticon_compatibility
    end

    # 文字コード変換
    def to_internal(str)
      if unicode_emoticon?
        # Unicode絵文字を数値参照に変換
        str = Jpmobile::Emoticon.external_to_unicodecr_unicode60(Jpmobile::Util.utf8(str))
      else
        # SoftBank絵文字を数値参照に変換
        str = Jpmobile::Emoticon.external_to_unicodecr_softbank(Jpmobile::Util.utf8(str))
      end
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon.unicodecr_to_utf8(str)
    end
    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      if unicode_emoticon?
        str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_UNICODE_EMOTICON, false)
      else
        # 数値参照を絵文字コードに変換
        str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK, false)
      end

      [str, charset]
    end

    def unicode_emoticon?
      @request.user_agent.match(/ OS (\d)_/) and $1.to_i >= 5
    end
  end
end
