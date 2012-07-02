# -*- coding: utf-8 -*-
# =iPhone

module Jpmobile::Mobile
  # ==iPhone
  class Iphone < SmartPhone
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPhone/

    include Jpmobile::Mobile::UnicodeEmoticon
  end
end
