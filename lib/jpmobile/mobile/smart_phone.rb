# -*- coding: utf-8 -*-
# =スマートフォンの親クラス

module Jpmobile::Mobile
  class SmartPhone < AbstractMobile
    # 無効化
    def valid_ip?
      false
    end

    # cookie は有効と見なす
    def supports_cookie?
      true
    end

    # smartphone なので true
    def smart_phone?
      true
    end
  end
end
