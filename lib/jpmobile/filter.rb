# = 文字コードフィルタ
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

require 'scanf'

class ActionController::Base #:nodoc:
  def self.mobile_filter(options={})
    options = {:emoticon=>true, :hankaku=>false}.update(options)

    if options[:emoticon]
      around_filter Jpmobile::Filter::Emoticon::Outer.new # 外部エンコーディング<->数値文字参照
    end
    around_filter Jpmobile::Filter::Sjis.new
    if options[:emoticon]
      around_filter Jpmobile::Filter::Emoticon::Inner.new # 数値文字参照<->UTF-8
    end
    if options[:hankaku]
      around_filter Jpmobile::Filter::HankakuKana.new
    end
  end
end

module Jpmobile
  # =文字コードフィルタモジュール。
  module Filter
    # 文字コードフィルタのベースクラス。
    class Base
      # 外部コードから内部コードに変換
      def before(controller)
        if respond_to?(:to_internal) && apply_incoming?(controller)
          Util.deep_apply(controller.params) do |value|
            value = to_internal(value, controller)
          end
        end
      end
      # 内部コードから外部コードに変換
      def after(controller)
        if respond_to?(:to_external) && apply_outgoing?(controller) && controller.response.body.is_a?(String)
          controller.response.body = to_external(controller.response.body, controller)
          after_after(controller) if respond_to? :after_after
        end
      end
      # 入力時(params)にこのフィルタを適用するか
      def apply_incoming?(controller); true; end
      # 出力時(response.body)にこのフィルタを適用するべきか
      def apply_outgoing?(controller); true; end
    end

    # 携帯電話の場合にのみ適用したい場合に Jpmobile::Base の派生クラスに include する。
    module ApplyOnlyForMobile
      def apply_incoming?(controller)
        controller.request.mobile?
      end
      def apply_outgoing?(controller)
        [nil, "text/html", "application/xhtml+xml"].include?(controller.response.content_type) &&
          controller.request.mobile?
      end
    end

    # Shift_JISとUnicodeのフィルタ(NKFを使用)
    class Sjis < Base
      # UTF-8からShift_JISに変換する。
      def to_external(str, controller)
        NKF.nkf('-m0 -x -Ws', str)
      end
      # Shift_JISからUTF-8に変換する。
      def to_internal(str, controller)
        NKF.nkf('-m0 -x -Sw', str)
      end
      # afterfilterを実行した後に実行する。
      def after_after(controller)
        unless controller.response.body.blank?
          # 500.htmlなどをUTF-8で書いたとき、docomoで文字化けするのを防ぐため
          # response_bodyが空の場合はShift_JISを指定しない
          controller.response.charset = "Shift_JIS"
        end
      end
      # to_internalを適用するべきかどうかを返す。
      def apply_incoming?(controller)
        # Vodafone 3G/Softbank(Shift-JISにすると絵文字で不具合が生じる)以外の
        # 携帯電話の場合に適用する。
        mobile = controller.request.mobile
        mobile && !(mobile.instance_of?(Jpmobile::Mobile::Vodafone)||mobile.instance_of?(Jpmobile::Mobile::Softbank))
      end
      def apply_outgoing?(controller)
        [nil, "text/html", "application/xhtml+xml"].include?(controller.response.content_type) &&
          apply_incoming?(controller)
      end
    end

    # テーブルに基づくフィルタ
    class FilterTable < Base
      cattr_reader :internal, :external
      def to_internal(str, controller)
        filter(str, external, internal)
      end
      def to_external(str, controller)
        filter(str, internal, external)
      end
      private
      def filter(str, from, to)
        str = str.clone
        from.each_with_index do |int, i|
          str.gsub!(int, to[i])
        end
        str
      end
    end

    # 半角カナと全角カナのフィルタ
    class HankakuKana < FilterTable
      include ApplyOnlyForMobile
      @@internal = %w(ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ ビ ブ ベ ボ パ ピ プ ペ ポ ヴ ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ヲ ン ャ ュ ョ ァ ィ ゥ ェ ォ ッ ゛ ゜ ー 。 「 」 、 ・).freeze
      @@external = %w(ｶﾞ ｷﾞ ｸﾞ ｹﾞ ｺﾞ ｻﾞ ｼﾞ ｽﾞ ｾﾞ ｿﾞ ﾀﾞ ﾁﾞ ﾂﾞ ﾃﾞ ﾄﾞ ﾊﾞ ﾋﾞ ﾌﾞ ﾍﾞ ﾎﾞ ﾊﾟ ﾋﾟ ﾌﾟ ﾍﾟ ﾎﾟ ｳﾞ ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ｦ ﾝ ｬ ｭ ｮ ｧ ｨ ｩ ｪ ｫ ｯ ﾞ ﾟ ｰ ｡ ｢ ｣ ､ ･).freeze
    end

    # 絵文字変換フィルタ
    module Emoticon
      # 絵文字Outer
      # 外部エンコーディング(携帯電話側)とUnicode数値文字参照を相互に変換。
      class Outer < Base
      include ApplyOnlyForMobile
        def to_internal(str, controller)
          method_name = "external_to_unicodecr_" +
            controller.request.mobile.class.name[/::(\w*)$/, 1].downcase
          if Jpmobile::Emoticon.respond_to?(method_name)
            Jpmobile::Emoticon.send(method_name, str)
          else
            str # 対応する変換メソッドが定義されていない場合は素通し
          end
        end
        def to_external(str, controller)
          # 使用する変換テーブルの決定
          table = nil
          to_sjis = false
          case controller.request.mobile
          when Jpmobile::Mobile::Docomo
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO
            to_sjis = true
          when Jpmobile::Mobile::Au
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_AU
            to_sjis = true
          when Jpmobile::Mobile::Jphone
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
            to_sjis = true
          when Jpmobile::Mobile::Softbank
            table = Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK
          end

          Jpmobile::Emoticon::unicodecr_to_external(str, table, to_sjis)
        end
      end
      # 絵文字Inner
      # Unicode数値文字参照とUTF-8を相互に変換
      class Inner < Base
        include ApplyOnlyForMobile
        def to_internal(str, controller)
          Jpmobile::Emoticon::unicodecr_to_utf8(str)
        end
        def to_external(str, controller)
          Jpmobile::Emoticon::utf8_to_unicodecr(str)
        end
      end
    end
  end
end
