# -*- coding: utf-8 -*-
# = 半角変換フィルター
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

class ActionController::Base #:nodoc:
  def self.hankaku_filter(options={})
    options = {:input => false}.update(options)

    before_filter lambda {|controller| Jpmobile::HankakuFilter.before(controller, options)}
    after_filter  lambda {|controller| Jpmobile::HankakuFilter.after(controller, options)}
  end

  def self.mobile_filter(options={})
    STDERR.puts "Method mobile_filter is now deprecated. Use hankaku_filter instead for Hankaku-conversion."

    self.hankaku_filter(options)
  end
end

module Jpmobile
  module HankakuFilter
    module_function

    # 入出力フィルタの適用条件
    def apply_incoming?(controller)
      controller.request.mobile?
    end
    def apply_outgoing?(controller)
      controller.request.mobile? and
        [nil, "text/html", "application/xhtml+xml"].include?(controller.response.content_type)
    end

    def before(controller, options = {})
      if apply_incoming?(controller)
        Util.deep_apply(controller.params) do |value|
          value = to_internal(value, options)
        end
      end
    end
    # 内部コードから外部コードに変換
    def after(controller, options = {})
      if apply_outgoing?(controller) and controller.response.body.is_a?(String)
        if controller.request.mobile?
          options.merge!(:charset => controller.request.mobile.default_charset)
        end
        controller.response.body = to_external(controller.response.body, options)
      end
    end

    @@zen_han = {"ガ" => "ｶﾞ", "ギ" => "ｷﾞ", "グ" => "ｸﾞ", "ゲ" => "ｹﾞ", "ゴ" => "ｺﾞ", "ザ" => "ｻﾞ", "ジ" => "ｼﾞ", "ズ" => "ｽﾞ", "ゼ" => "ｾﾞ", "ゾ" => "ｿﾞ", "ダ" => "ﾀﾞ", "ヂ" => "ﾁﾞ", "ヅ" => "ﾂﾞ", "デ" => "ﾃﾞ", "ド" => "ﾄﾞ", "バ" => "ﾊﾞ", "ビ" => "ﾋﾞ", "ブ" => "ﾌﾞ", "ベ" => "ﾍﾞ", "ボ" => "ﾎﾞ", "パ" => "ﾊﾟ", "ピ" => "ﾋﾟ", "プ" => "ﾌﾟ", "ペ" => "ﾍﾟ", "ポ" => "ﾎﾟ", "ヴ" => "ｳﾞ", "ア" => "ｱ", "イ" => "ｲ", "ウ" => "ｳ", "エ" => "ｴ", "オ" => "ｵ", "カ" => "ｶ", "キ" => "ｷ", "ク" => "ｸ", "ケ" => "ｹ", "コ" => "ｺ", "サ" => "ｻ", "シ" => "ｼ", "ス" => "ｽ", "セ" => "ｾ", "ソ" => "ｿ", "タ" => "ﾀ", "チ" => "ﾁ", "ツ" => "ﾂ", "テ" => "ﾃ", "ト" => "ﾄ", "ナ" => "ﾅ", "ニ" => "ﾆ", "ヌ" => "ﾇ", "ネ" => "ﾈ", "ノ" => "ﾉ", "ハ" => "ﾊ", "ヒ" => "ﾋ", "フ" => "ﾌ", "ヘ" => "ﾍ", "ホ" => "ﾎ", "マ" => "ﾏ", "ミ" => "ﾐ", "ム" => "ﾑ", "メ" => "ﾒ", "モ" => "ﾓ", "ヤ" => "ﾔ", "ユ" => "ﾕ", "ヨ" => "ﾖ", "ラ" => "ﾗ", "リ" => "ﾘ", "ル" => "ﾙ", "レ" => "ﾚ", "ロ" => "ﾛ", "ワ" => "ﾜ", "ヲ" => "ｦ", "ン" => "ﾝ", "ャ" => "ｬ", "ュ" => "ｭ", "ョ" => "ｮ", "ァ" => "ｧ", "ィ" => "ｨ", "ゥ" => "ｩ", "ェ" => "ｪ", "ォ" => "ｫ", "ッ" => "ｯ", "゛" => "ﾞ", "゜" => "ﾟ", "ー" => "ｰ", "。" => "｡", "「" => "｢", "」" => "｣", "、" => "､", "・" => "･", "！" => "!", "？" => "?"}
    @@han_zen = @@zen_han.invert

    def to_internal(str, options = {})
      filter(str, @@han_zen)
    end
    def to_external(str, options = {})
      unless options[:input]
        filter(str, @@zen_han)
      else
        encoding = (str =~ /^\s*<[^Hh>]*html/) and str.respond_to?(:encoding)
        nokogiri_klass =
          (str =~ /^\s*<[^Hh>]*html/) ? Nokogiri::HTML::Document : Nokogiri::HTML::DocumentFragment
        doc = if encoding
                nokogiri_klass.parse(str, nil, "UTF-8")
              else
                nokogiri_klass.parse(str)
              end

        doc = convert_text_content(doc)

        html = doc.to_html.gsub("\xc2\xa0","&nbsp;")
        html = html.gsub(/charset=[a-z0-9\-]+/i, "charset=#{options[:charset]}") if options[:charset]
        html
      end
    end

    def filter(str, table)
      str = str.clone

      # 一度UTF-8に変換
      before_encoding = nil
      if str.respond_to?(:force_encoding)
        before_encoding = str.encoding
        str.force_encoding("UTF-8")
      end

      str = replace_chars(str, table)

      # 元に戻す
      if before_encoding
        str.force_encoding(before_encoding)
      end

      str
    end

    def replace_chars(str, table)
      @regexp_cache ||= {}
      str.gsub(@regexp_cache[table.object_id] ||= Regexp.union(table.keys), table)
    end

    # 再帰的に探す
    def convert_text_content(document)
      document.children.each do |element|
        if element.kind_of?(Nokogiri::XML::Text)
          unless element.parent.node_name == "textarea"
            # textarea 以外のテキストなら content を変換
            element.content = filter(element.content, @@zen_han)
          end
        elsif element.node_name == "input" and ["submit", "reset", "button"].include?(element["type"])
          # テキスト以外でもボタンの value は変換
          element["value"] = filter(element["value"], @@han_zen)
        elsif element.children.any?
          # 子要素があれば再帰的に変換
          element = convert_text_content(element)
        end
      end

      document
    end
  end
end
