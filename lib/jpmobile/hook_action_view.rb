# -*- coding: utf-8 -*-
# = viewの自動切り替え
#
#:stopdoc:
# helperを追加
ActionView::Base.class_eval { include Jpmobile::Helpers }
#:startdoc:

# ActionView を拡張して携帯からのアクセスの場合に携帯向けビューを優先表示する。
# Vodafone携帯(request.mobile == Jpmobile::Mobile::Vodafone)の場合、
#   index_mobile_vodafone.html.erb
#   index_mobile_softbank.html.erb
#   index_mobile.html.erb
#   index.html.erb
# の順にテンプレートが検索される。
# BUG: 現状、上記の例では index.html.erb が存在しない場合に振り分けが行われない
# (ダミーファイルを置くことで回避可能)。
module ActionView
  class PathSet
    attr_accessor :controller

    def find_with_jpmobile(path, prefix = nil, partial = false, details = {}, key = nil) #:nodoc:
      if controller and controller.kind_of?(ActionController::Base) and
          (controller.request.mobile? or controller.request.smart_phone?)
        return path if path.respond_to?(:render)
        template_candidates = mobile_template_candidates

        each do |load_path|
          template_candidates.each do |template_postfix|
            templates = load_path.find_all("#{path}_#{template_postfix}", prefix, partial, details, key)
            return templates.first unless templates.empty?
          end
        end
      end

      find_without_jpmobile(path, prefix, partial, details, key)
    end

    alias_method_chain :find, :jpmobile  #:nodoc:

    def mobile_template_candidates #:nodoc:
      candidates = []

      view_class, parent_class, template_prefix = case controller.request.mobile
      when ::Jpmobile::Mobile::SmartPhone
        [controller.request.mobile.class, ::Jpmobile::Mobile::SmartPhone, "smart_phone"]
      when ::Jpmobile::Mobile::AbstractMobile
        [controller.request.mobile.class, ::Jpmobile::Mobile::AbstractMobile, "mobile"]
      else
        [nil, nil, nil]
      end

      if view_class and parent_class
        find_mobile_template(view_class, parent_class, template_prefix).push(template_prefix)
      else
        []
      end
    end

    private
    def find_mobile_template(klass, parent, prefix)
      if klass == parent
        []
      else
        find_mobile_template(klass.superclass, parent, prefix).unshift("#{prefix}_#{klass.to_s.split(/::/).last.underscore}")
      end
    end
  end
end
