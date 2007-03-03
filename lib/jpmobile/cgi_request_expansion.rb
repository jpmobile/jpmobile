# ActionController::CgiRequest を拡張して jpmobile の各機能を提供する。
class ActionController::CgiRequest
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
        Jpmobile::Mobile::Docomo.new(self)
      when /^KDDI-/
        Jpmobile::Mobile::Au.new(self)
      when /^J-PHONE/
        Jpmobile::Mobile::Jphone.new(self)
      when /^Vodafone/
        Jpmobile::Mobile::Vodafone.new(self)
      when /^SoftBank/
        Jpmobile::Mobile::Softbank.new(self)
      when /^Mozilla\/3.0\(DDIPOCKET/
        Jpmobile::Mobile::Ddipocket.new(self)
      when /^Mozilla\/3.0\(WILLCOM/
        Jpmobile::Mobile::Willcom.new(self)
      else
        nil
      end
    end
  end
