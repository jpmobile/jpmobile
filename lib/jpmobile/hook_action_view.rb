# = viewの自動切り替え
#
# Rails 2.1.0 対応 http://d.hatena.ne.jp/kusakari/20080620/1213931903
# thanks to id:kusakari
#
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
# BUG: 現状、上記の例では index.rhtml が存在しない場合に振り分けが行われない
# (ダミーファイルを置くことで回避可能)。

class ActionView::Base #:nodoc:
  alias render_file_without_jpmobile render_file #:nodoc:
  alias render_partial_without_jpmobile render_partial #:nodoc:

  def render_file(template_path, use_full_path = true, local_assigns = {})
    mobile_path = mobile_template_path(template_path)
    return mobile_path.nil? ? render_file_without_jpmobile(template_path, use_full_path, local_assigns) :
                              render_file_without_jpmobile(mobile_path, use_full_path, local_assigns)
  end

  def render_partial(partial_path, object_assigns = nil, local_assigns = {}) #:nodoc:
    mobile_path = mobile_template_path(partial_path, true) if partial_path.class === "String"
    return mobile_path.nil? ? render_partial_without_jpmobile(partial_path, object_assigns, local_assigns) :
    render_partial_without_jpmobile(mobile_path, object_assigns, local_assigns)
  end

  def mobile_template_path(template_path, partial=false)
    if controller.is_a?(ActionController::Base) && m = controller.request.mobile
      candidates = []
      c = m.class
      while c != Jpmobile::Mobile::AbstractMobile
        candidates << "mobile_"+c.to_s.split(/::/).last.downcase
        c = c.superclass
      end
      candidates << "mobile"

      candidates.each do |v|
        mobile_path = "#{template_path}_#{v}"
        if partial
          # ActionView::PartialTemplate#extract_partial_name_and_path の動作を模倣
          if mobile_path.include?('/')
            path = File.dirname(mobile_path)
            partial_name = File.basename(mobile_path)
          else
            path = self.controller.class.controller_path
            partial_name = mobile_path
          end
          full_path = File.join(path, "_#{partial_name}")
        else
          full_path = mobile_path
        end
        if finder.file_exists?(full_path)
          return mobile_path
        end
      end
    end
    return nil
  end
end
