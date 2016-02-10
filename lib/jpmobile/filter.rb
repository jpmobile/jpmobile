# -*- coding: utf-8 -*-
# = 半角変換フィルター
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

ActiveSupport.on_load(:action_controller) do
  def self.hankaku_filter(options={})
    before_action Jpmobile::HankakuFilter.new(options)
    after_action  Jpmobile::HankakuFilter.new(options)
  end

  def self.mobile_filter(options={})
    STDERR.puts "Method mobile_filter is now deprecated. Use hankaku_filter instead for Hankaku-conversion."

    self.hankaku_filter(options)
  end
end

module Jpmobile
  class HankakuFilter
    cattr_accessor(:zen_to_han_table) do
      {
        "ガ" => "ｶﾞ", "ギ" => "ｷﾞ", "グ" => "ｸﾞ", "ゲ" => "ｹﾞ", "ゴ" => "ｺﾞ",
        "ザ" => "ｻﾞ", "ジ" => "ｼﾞ", "ズ" => "ｽﾞ", "ゼ" => "ｾﾞ", "ゾ" => "ｿﾞ",
        "ダ" => "ﾀﾞ", "ヂ" => "ﾁﾞ", "ヅ" => "ﾂﾞ", "デ" => "ﾃﾞ", "ド" => "ﾄﾞ",
        "バ" => "ﾊﾞ", "ビ" => "ﾋﾞ", "ブ" => "ﾌﾞ", "ベ" => "ﾍﾞ", "ボ" => "ﾎﾞ",
        "パ" => "ﾊﾟ", "ピ" => "ﾋﾟ", "プ" => "ﾌﾟ", "ペ" => "ﾍﾟ", "ポ" => "ﾎﾟ",
        "ヴ" => "ｳﾞ",
        "ア" => "ｱ", "イ" => "ｲ", "ウ" => "ｳ", "エ" => "ｴ", "オ" => "ｵ",
        "カ" => "ｶ", "キ" => "ｷ", "ク" => "ｸ", "ケ" => "ｹ", "コ" => "ｺ",
        "サ" => "ｻ", "シ" => "ｼ", "ス" => "ｽ", "セ" => "ｾ", "ソ" => "ｿ",
        "タ" => "ﾀ", "チ" => "ﾁ", "ツ" => "ﾂ", "テ" => "ﾃ", "ト" => "ﾄ",
        "ナ" => "ﾅ", "ニ" => "ﾆ", "ヌ" => "ﾇ", "ネ" => "ﾈ", "ノ" => "ﾉ",
        "ハ" => "ﾊ", "ヒ" => "ﾋ", "フ" => "ﾌ", "ヘ" => "ﾍ", "ホ" => "ﾎ",
        "マ" => "ﾏ", "ミ" => "ﾐ", "ム" => "ﾑ", "メ" => "ﾒ", "モ" => "ﾓ",
        "ヤ" => "ﾔ", "ユ" => "ﾕ", "ヨ" => "ﾖ",
        "ラ" => "ﾗ", "リ" => "ﾘ", "ル" => "ﾙ", "レ" => "ﾚ", "ロ" => "ﾛ",
        "ワ" => "ﾜ", "ヲ" => "ｦ", "ン" => "ﾝ",
        "ャ" => "ｬ", "ュ" => "ｭ", "ョ" => "ｮ",
        "ァ" => "ｧ", "ィ" => "ｨ", "ゥ" => "ｩ", "ェ" => "ｪ", "ォ" => "ｫ",
        "ッ" => "ｯ",
        "゛" => "ﾞ", "゜" => "ﾟ", "ー" => "ｰ", "。" => "｡",
        "「" => "｢", "」" => "｣",
        "、" => "､", "・" => "･", "！" => "!", "？" => "?",
      }
    end

    class << self
      def hankaku_format(str)
        replace_chars(str, zen_to_han_table)
      end

      def zenkaku_format(str)
        replace_chars(str, han_to_zen_table)
      end

      private

      def replace_chars(str, table)
        @regexp_cache ||= {}
        str.gsub(@regexp_cache[table.object_id] ||= Regexp.union(table.keys), table)
      end

      def han_to_zen_table
        @han_to_zen_table ||= zen_to_han_table.invert
      end
    end

    def initialize(options = {})
      @options = {
        :input => false,
      }.merge(options)

      @controller = nil
    end

    def before(controller)
      @controller = controller
      if apply_incoming?
        Util.deep_apply(@controller.params) do |value|
          value = to_internal(value)
        end
      end
    end

    # 内部コードから外部コードに変換
    def after(controller)
      @controller = controller
      if apply_outgoing? and @controller.response.body.is_a?(String)
        @controller.response.body = to_external(@controller.response.body)
      end
    end

    private

    # 入出力フィルタの適用条件
    def apply_incoming?
      @controller.request.mobile?
    end

    def apply_outgoing?
      @controller.request.mobile? and
        [nil, "text/html", "application/xhtml+xml"].include?(@controller.response.content_type)
    end

    def to_internal(str)
      filter(:zenkaku, str)
    end

    def to_external(str)
      unless @options[:input]
        filter(:hankaku, str)
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
        html = html.gsub(/charset=[a-z0-9\-]+/i, "charset=#{default_charset}") if default_charset
        html
      end
    end

    def filter(method, str)
      str = str.dup

      # 一度UTF-8に変換
      before_encoding = nil
      if str.respond_to?(:force_encoding)
        before_encoding = str.encoding
        str.force_encoding("UTF-8")
      end

      str = self.class.send("#{method}_format", str)

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
            element.content = filter(:hankaku, element.content)
          end
        elsif element.node_name == "input" and ["submit", "reset", "button"].include?(element["type"])
          # テキスト以外でもボタンの value は変換
          element["value"] = filter(:hankaku, element["value"])
        elsif element.children.any?
          # 子要素があれば再帰的に変換
          element = convert_text_content(element)
        end
      end

      document
    end

    def default_charset
      if @controller.request.mobile?
        @controller.request.mobile.default_charset
      end
    end
  end
end
