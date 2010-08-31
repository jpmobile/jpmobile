# -*- coding: utf-8 -*-
# =Android

module Jpmobile::Mobile
  # ==Android
  class Android < SmartPhone
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /Android/
  end
end
