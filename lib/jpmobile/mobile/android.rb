# -*- coding: utf-8 -*-
# =Android

module Jpmobile::Mobile
  # ==Android
  class Android < SmartPhone
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /Android/

    # 文字コード変換
    def to_internal(str)
      # Google絵文字を数値参照に変換
      str = Jpmobile::Emoticon.external_to_unicodecr_android(Jpmobile::Util.utf8(str))
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon.unicodecr_to_utf8(str)
    end
    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)

      [str, charset]
    end
  end
end
