# =iPhone

module Jpmobile::Mobile
  # ==iPhone
  class Iphone < SmartPhone
    include Jpmobile::Mobile::UnicodeEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPhone/
  end
end
