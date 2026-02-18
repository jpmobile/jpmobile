# =iPad

module Jpmobile::Mobile
  # ==iPad
  class Ipad < Tablet
    include Jpmobile::Mobile::UnicodeEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /iPad/

    class << self
      # Client Hints でリクエストがこのクラスに属するか調べる
      def check_client_hints(env)
        env['HTTP_SEC_CH_UA_PLATFORM'] == '"iOS"' &&
          env['HTTP_SEC_CH_UA_MOBILE'] == '?0'
      end
    end
  end
end
