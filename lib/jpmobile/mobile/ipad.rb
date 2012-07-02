# -*- coding: utf-8 -*-
# =Android

module Jpmobile::Mobile
  # ==iPad
  class Ipad < Tablet
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPad/

    include Jpmobile::Mobile::UnicodeEmoticon
  end
end
