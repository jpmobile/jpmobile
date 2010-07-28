# -*- coding: utf-8 -*-
# Vodafone
module Jpmobile::Mobile
  # ==Vodafone 3G携帯電話(SoftBank含まず)
  # スーパクラスはSoftbank。
  class Vodafone < Softbank
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^(Vodafone|Vemulator)/
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /^.+@[dhtcrknsq]\.vodafone\.ne\.jp$/

    # cookieに対応しているか？
    def supports_cookie?
      true
    end
  end
end
