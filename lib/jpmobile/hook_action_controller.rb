require 'action_pack'

class ActionController::Base
  include Jpmobile::Helpers
  before_filter :gettext_force_ja_for_mobile
  # gettextが組み込まれている場合、携帯電話からのアクセスをjaロケールに強制する。
  def gettext_force_ja_for_mobile
    begin
      ::GetText.locale = 'ja' if request.mobile?
    rescue NameError
    end
  end

  class << self
    def view_paths=(value)
      @view_paths = ActionView::Base.process_view_paths(value) if value
    end
  end

  def view_paths=(value)
    @view_paths = ActionView::Base.process_view_paths(value, controller) if value
  end
end
