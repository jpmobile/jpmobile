class ActionController::Base
  before_filter :gettext_force_ja_for_mobile
  # gettextが組み込まれている場合、携帯電話からのアクセスをjaロケール強制する。
  def gettext_force_ja_for_mobile
    begin
      ::GetText.locale = request.mobile? ? 'ja' : nil
    rescue NameError
    end
  end
end
