# =Android

module Jpmobile::Mobile
  # ==AndroidTablet
  class AndroidTablet < Tablet
    include Jpmobile::Mobile::GoogleEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = Regexp.union(/(?!Android.+Mobile)Android/, /Android.+SC-01C/)
  end
end
