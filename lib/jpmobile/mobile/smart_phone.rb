# =スマートフォンの親クラス

module Jpmobile::Mobile
  class SmartPhone < AbstractMobile
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
