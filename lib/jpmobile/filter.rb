# = 文字コードフィルタ
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

class ActionController::Base #:nodoc:
  def self.mobile_filter(options={})
    around_filter Jpmobile::Filter::Sjis.new
    around_filter Jpmobile::Filter::HankakuKana.new
  end
end

module Jpmobile
  # =文字コードフィルタモジュール。
  module Filter
    # 文字コードフィルタのベースクラス。
    class Base
      def initialize
        @counter = 0 # render :component 時に多重で適用されるのを防ぐ
      end
      # 外部コードから内部コードに変換
      def before(controller)
        @counter += 1
        return unless @counter == 1
        if respond_to?(:to_internal) && apply_incoming?(controller)
          deep_each(controller.params) do |value|
            value = to_internal(value)
          end
        end
      end
      # 内部コードから外部コードに変換
      def after(controller)
        @counter -= 1
        return unless @counter.zero?
        if respond_to?(:to_external) && apply_outgoing?(controller)
          controller.response.body = to_external(controller.response.body)
          after_after(controller) if respond_to? :after_after
        end
      end
      # 入力時(params)にこのフィルタを適用するか
      def apply_incoming?(controller); true; end
      # 出力時(response.body)にこのフィルタを適用するべきか
      def apply_outgoing?(controller); true; end
      private
      # ハッシュ等をなめる。
      def deep_each(obj, &proc)
        if obj.is_a? Hash
          obj.each_pair do |key, value|
            obj[key] = deep_each(value, &proc)
          end
        elsif obj.is_a? Array
          obj.collect!{|value| deep_each(value, &proc)}
        elsif not (obj==nil || obj.is_a?(TrueClass) || obj.is_a?(FalseClass))
          obj = obj.to_param if obj.respond_to?(:to_param)
          proc.call(obj)
        end
      end
    end

    # Shift_JISとUnicodeのフィルタ(NKFを使用)
    class Sjis < Base
      def to_external(str)
        NKF.nkf('-m0 -x -Ws', str)
      end
      def to_internal(str)
        NKF.nkf('-m0 -Sw', str)
      end
      def after_after(controller)
        controller.response.charset = "Shift_JIS"
      end
      def apply_incoming?(controller)
        # Vodafone 3G/Softbank(Shift-JISにすると絵文字で不具合が生じる)以外の
        # 携帯電話の場合に適用する。
        controller.request.mobile? && !controller.request.mobile.is_a?(Jpmobile::Mobile::Vodafone)
      end
      alias apply_outgoing? apply_incoming?
    end

    # テーブルに基づくフィルタ
    class FilterTable < Base
      cattr_reader :internal, :external
      def to_internal(str)
        filter(str, external, internal)
      end
      def to_external(str)
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
      @@internal = %w(ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ ビ ブ ベ ボ パ ピ プ ペ ポ ヴ ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ヲ ン ャ ュ ョ ァ ィ ゥ ェ ォ ッ ゛ ゜ ー ).freeze
      @@external = %w(ｶﾞ ｷﾞ ｸﾞ ｹﾞ ｺﾞ ｻﾞ ｼﾞ ｽﾞ ｾﾞ ｿﾞ ﾀﾞ ﾁﾞ ﾂﾞ ﾃﾞ ﾄﾞ ﾊﾞ ﾋﾞ ﾌﾞ ﾍﾞ ﾎﾞ ﾊﾟ ﾋﾟ ﾌﾟ ﾍﾟ ﾎﾟ ｳﾞ ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ｦ ﾝ ｬ ｭ ｮ ｧ ｨ ｩ ｪ ｫ ｯ ﾞ ﾟ ｰ).freeze
      def apply_incoming?(controller)
        # 携帯電話の場合に適用する。
        controller.request.mobile?
      end
      alias apply_outgoing? apply_incoming?
    end
  end
end
