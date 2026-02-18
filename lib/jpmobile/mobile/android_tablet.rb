# =Android

module Jpmobile::Mobile
  # ==AndroidTablet
  class AndroidTablet < Tablet
    include Jpmobile::Mobile::GoogleEmoticon

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = Regexp.union(/^(?!.+Mobile).+(?=Android).+$/, /Android.+SC-01C/)

    class << self
      # Client Hints でリクエストがこのクラスに属するか調べる
      def check_client_hints(env)
        env['HTTP_SEC_CH_UA_PLATFORM'] == '"Android"' &&
          env['HTTP_SEC_CH_UA_MOBILE'] == '?0'
      end
    end
  end
end
