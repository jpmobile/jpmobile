# =iPhone

module Jpmobile::Mobile
  # ==iPhone
  class Iphone < SmartPhone
    include Jpmobile::Mobile::UnicodeEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPhone/

    class << self
      # Client Hints でリクエストがこのクラスに属するか調べる
      def check_client_hints(env)
        env['HTTP_SEC_CH_UA_PLATFORM'] if env['HTTP_SEC_CH_UA_PLATFORM'] == '"iOS"' &&
                                          env['HTTP_SEC_CH_UA_MOBILE'] == '?1'
      end
    end
  end
end
