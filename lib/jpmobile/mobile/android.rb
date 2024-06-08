# =Android

module Jpmobile::Mobile
  # ==Android
  class Android < SmartPhone
    include Jpmobile::Mobile::GoogleEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /Android/
  end
end
