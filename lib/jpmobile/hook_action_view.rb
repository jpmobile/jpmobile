#:stopdoc:
# helperを追加
ActionView::Base.class_eval { include Jpmobile::Helpers }
#:startdoc:

# ActionView::Base を拡張して携帯からのアクセスの場合に携帯向けビューを優先表示する。
# Vodafone携帯(request.mobile == Jpmobile::Mobile::Vodafone)の場合、
#   index_mobile_vodafone.rhtml
#   index_mobile_softbank.rhtml
#   index_mobile.rhtml
#   index.rhtml
# の順にテンプレートが検索される。
class ActionView::Base #:nodoc:
  alias render_file_without_mobile render_file #:nodoc:
  def render_file(template_path, use_full_path = true, local_assigns = {})
    if controller.is_a?(ActionController::Base) && m = controller.request.mobile
      vals = []
      c = m.class
      while c != Jpmobile::Mobile::AbstractMobile
        vals << "mobile_"+c.to_s.split(/::/).last.downcase
        c = c.superclass
      end
      vals << "mobile"

      vals.each do |v|
        mobile_path = "#{template_path}_#{v}"
        if file_exists?(mobile_path)
          return render_file_without_mobile(mobile_path, use_full_path, local_assigns)
        end
      end
    end
    render_file_without_mobile(template_path, use_full_path, local_assigns)
  end
end
