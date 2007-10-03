# ActionController::AbstractRequest を拡張して jpmobile の各機能を提供する。
class ActionController::AbstractRequest
  # 環境変数 HTTP_USER_AGENT を返す。
  def user_agent
    env['HTTP_USER_AGENT']
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
    Jpmobile::Mobile.constants.each do |const|
      c = Jpmobile::Mobile.const_get(const)
      return c.new(self) if c::USER_AGENT_REGEXP && user_agent =~ c::USER_AGENT_REGEXP
    end
    nil
  end
end
