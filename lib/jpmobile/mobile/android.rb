# =Android

module Jpmobile::Mobile
  # ==Android
  class Android < SmartPhone
    include Jpmobile::Mobile::GoogleEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /Android/

    class << self
      # Client Hints でリクエストがこのクラスに属するか調べる
      def check_client_hints(env)
        env['HTTP_SEC_CH_UA_PLATFORM'] if env['HTTP_SEC_CH_UA_PLATFORM'] == '"Android"' &&
                                          env['HTTP_SEC_CH_UA_MOBILE'] == '?1'
      end
    end
  end
end
