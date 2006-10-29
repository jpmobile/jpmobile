module Jpmobile
  # ActionController::CgiRequest に include して
  # jpmobile の各機能を提供する。
  module CgiRequestExpansion
    # 環境変数 HTTP_USER_AGENT を返す。
    def user_agent
      env['HTTP_USER_AGENT']
    end

    # 携帯電話からであれば +true+を、そうでなければ +false+ を返す。
    def mobile?
      mobile != nil
    end

    # 携帯電話の機種に応じて、
    # Mobile::Docomo、
    # Mobile::Au、
    # Mobile::Jphone、Mobile::Vodafone、Mobile::Softbank、
    # Mobile::Willcom、Mobile::Ddipocket
    # のインスタンスを返す。
    # 携帯電話でない場合はnilを返す。
    def mobile
      case user_agent
      when /^DoCoMo/
        Mobile::Docomo.new(self)
      when /^KDDI-/
        Mobile::Au.new(self)
      when /^J-PHONE/
        Mobile::Jphone.new(self)
      when /^Vodafone/
        Mobile::Vodafone.new(self)
      when /^Softbank/
        Mobile::Softbank.new(self)
      when /^Mozilla\/3.0\(DDIPOCKET/
        Mobile::Ddipocket.new(self)
      when /^Mozilla\/3.0\(WILLCOM/
        Mobile::Willcom.new(self)
      else
        nil
      end
    end
  end
end
