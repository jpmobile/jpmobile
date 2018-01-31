# =iPad

module Jpmobile::Mobile
  # ==iPad
  class Ipad < Tablet
    include Jpmobile::Mobile::UnicodeEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPad/
  end
end
