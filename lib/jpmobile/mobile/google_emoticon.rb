# -*- coding: utf-8 -*-
module Jpmobile::Mobile
  module GoogleEmoticon
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
      # Google絵文字を数値参照に変換
      str = Jpmobile::Emoticon.external_to_unicodecr_google(Jpmobile::Util.utf8(str))
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon.unicodecr_to_utf8(str)
    end
    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_GOOGLE_EMOTICON, false)

      [str, charset]
    end
  end
end
