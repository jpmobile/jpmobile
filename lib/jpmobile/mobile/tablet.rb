# -*- coding: utf-8 -*-
# =タブレットの親クラス

module Jpmobile::Mobile
  class Tablet < SmartPhone
    # smartphone なので true
    def smart_phone?
      true
    end

    # tablet なので true
    def tablet?
      true
    end
  end
end
