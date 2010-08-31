# -*- coding: utf-8 -*-
# =DDI-POCKET
module Jpmobile::Mobile
  # ==DDI-POCKET
  # スーパクラスはWillcom。
  class Ddipocket < Willcom
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^Mozilla\/3.0\(DDIPOCKET/

    MAIL_ADDRESS_REGEXP = nil # DdipocketはEmail判定だとWillcomと判定させたい
  end
end
