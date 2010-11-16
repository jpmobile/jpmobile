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
        controller.response.body = to_external(controller.response.body, options)
      end
    end

    @@internal = %w(ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ ビ ブ ベ ボ パ ピ プ ペ ポ ヴ ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ヲ ン ャ ュ ョ ァ ィ ゥ ェ ォ ッ ゛ ゜ ー 。 「 」 、 ・ ！ ？).freeze
    @@external = %w(ｶﾞ ｷﾞ ｸﾞ ｹﾞ ｺﾞ ｻﾞ ｼﾞ ｽﾞ ｾﾞ ｿﾞ ﾀﾞ ﾁﾞ ﾂﾞ ﾃﾞ ﾄﾞ ﾊﾞ ﾋﾞ ﾌﾞ ﾍﾞ ﾎﾞ ﾊﾟ ﾋﾟ ﾌﾟ ﾍﾟ ﾎﾟ ｳﾞ ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ｦ ﾝ ｬ ｭ ｮ ｧ ｨ ｩ ｪ ｫ ｯ ﾞ ﾟ ｰ ｡ ｢ ｣ ､ ･ ! ?).freeze
    def to_internal(str, options = {})
      filter(str, @@external, @@internal)
    end
    def to_external(str, options = {})
      unless options[:input]
        filter(str, @@internal, @@external)
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

        doc.to_html
      end
    end

    def filter(str, from, to)
      str = str.clone

      # 一度UTF-8に変換
      before_encoding = nil
      if str.respond_to?(:force_encoding)
        before_encoding = str.encoding
        str.force_encoding("UTF-8")
      end

      from.each_with_index do |int, i|
        str.gsub!(int, to[i])
      end

      # 元に戻す
      if before_encoding
        str.force_encoding(before_encoding)
      end

      str
    end

    # 再帰的に探す
    def convert_text_content(document)
      document.children.each do |element|
        if element.kind_of?(Nokogiri::XML::Text)
          unless element.parent.node_name == "textarea"
            # textarea 以外のテキストなら content を変換
            element.content = filter(element.content, @@internal, @@external)
          end
        elsif element.node_name == "input" and ["submit", "reset", "button"].include?(element["type"])
          # テキスト以外でもボタンの value は変換
          element["value"] = filter(element["value"], @@internal, @@external)
        elsif element.children.any?
          # 子要素があれば再帰的に変換
          element = convert_text_content(element)
        end
      end

      document
    end
  end
end
