# jpmobile の各機能を提供するモジュール
# envメソッドと、parameter あるいは params メソッドが実装されている必要がある。
# 今のところはRack::RequestとActionController::AbstractRequestに対応しているはず。

module Jpmobile
  module RequestWithMobile
    # 環境変数 HTTP_USER_AGENT を返す。
    def user_agent
      env['HTTP_USER_AGENT']
    end

    # for reverse proxy.
    def remote_addr
      if respond_to? :remote_ip
        return __send__(:remote_ip)
      else
        return ( env["HTTP_X_FORWARDED_FOR"] ? env["HTTP_X_FORWARDED_FOR"].split(',').pop : env["REMOTE_ADDR"] )
      end
    end

    # 環境変数 HTTP_USER_AGENT を設定する。
    def user_agent=(str)
      self.env["HTTP_USER_AGENT"] = str
    end

    # 携帯電話からであれば +true+を、そうでなければ +false+ を返す。
    def mobile?
      mobile != nil
    end

    # 携帯電話の機種に応じて Mobile::xxx を返す。
    # 携帯電話でない場合はnilを返す。
    def mobile
      return @__mobile if @__mobile

      Jpmobile::Mobile.constants.each do |const|
        c = Jpmobile::Mobile.const_get(const)
        return @__mobile = c.new(self) if c::USER_AGENT_REGEXP && user_agent =~ c::USER_AGENT_REGEXP
      end
      nil
    end
  end
end

