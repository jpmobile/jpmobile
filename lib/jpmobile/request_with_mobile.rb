#
# jpmobile の各機能を提供するモジュール
# envメソッドが実装されている必要がある。

module Jpmobile
  module RequestWithMobile
    # 環境変数 HTTP_USER_AGENT を返す。
    def user_agent
      env['HTTP_USER_AGENT']
    end

    # for reverse proxy.
    def remote_addr
      if respond_to?(:remote_ip)
        __send__(:remote_ip)  # for Rails
      elsif respond_to?(:ip)
        __send__(:ip)         # for Rack
      else
        if env['HTTP_X_FORWARDED_FOR']
          env['HTTP_X_FORWARDED_FOR'].split(',').pop
        else
          env['REMOTE_ADDR']
        end
      end
    end

    # 環境変数 HTTP_USER_AGENT を設定する。
    def user_agent=(str)
      self.env['HTTP_USER_AGENT'] = str
    end

    # 携帯電話からであれば +true+を、そうでなければ +false+ を返す。
    def mobile?
      mobile and !mobile.smart_phone?
    end

    # スマートフォンであれば +true+を、そうでなければ +false+ を返す。
    def smart_phone?
      mobile and mobile.smart_phone?
    end

    # タブレットからであれば +true+を、そうでなければ +false+ を返す
    def tablet?
      mobile and mobile.tablet?
    end

    # 携帯電話の機種に応じて Mobile::xxx を返す。
    # 携帯電話でない場合はnilを返す。
    def mobile
      env['rack.jpmobile']
    end
  end

  module RequestWithMobileTesting
    def mobile
      Jpmobile::Mobile::AbstractMobile.carrier(env)
    end
  end
end
