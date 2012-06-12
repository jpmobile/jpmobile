# -*- coding: utf-8 -*-
# =BlackBerry

module Jpmobile::Mobile
  # ==BlackBerry
  class BlackBerry < SmartPhone
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /BlackBerry/
  end
end
