# -*- coding: utf-8 -*-
# =Android

module Jpmobile::Mobile
  # ==AndroidTablet
  class AndroidTablet < Tablet
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = Regexp.union(/(?!Android.+Mobile)Android/, /Android.+SC-01C/)

    include Jpmobile::Mobile::GoogleEmoticon
  end
end
