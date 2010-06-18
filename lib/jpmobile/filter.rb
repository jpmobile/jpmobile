# -*- coding: utf-8 -*-
# = 文字コードフィルタ
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

class ActionController::Base #:nodoc:
  def self.mobile_filter(options={})
    options = {:emoticon=>true, :hankaku=>false}.update(options)

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
  end
end
