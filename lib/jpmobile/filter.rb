# -*- coding: utf-8 -*-
# = 文字コードフィルタ
# thanks to masuidrive <masuidrive (at) masuidrive.jp>

class ActionController::Base #:nodoc:
  def self.mobile_filter(options={})
    options = {:emoticon=>true, :hankaku=>false}.update(options)

    if options[:hankaku]
      before_filter lambda {|controller| Jpmobile::HankakuFilter.before(controller)}
      after_filter  lambda {|controller| Jpmobile::HankakuFilter.after(controller)}
    end
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

    def before(controller)
      if apply_incoming?(controller)
        Util.deep_apply(controller.params) do |value|
          value = to_internal(value)
        end
      end
    end
    # 内部コードから外部コードに変換
    def after(controller)
      if apply_outgoing?(controller) and controller.response.body.is_a?(String)
        controller.response.body = to_external(controller.response.body)
      end
    end

    @@internal = %w(ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ ビ ブ ベ ボ パ ピ プ ペ ポ ヴ ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ヲ ン ャ ュ ョ ァ ィ ゥ ェ ォ ッ ゛ ゜ ー 。 「 」 、 ・).freeze
    @@external = %w(ｶﾞ ｷﾞ ｸﾞ ｹﾞ ｺﾞ ｻﾞ ｼﾞ ｽﾞ ｾﾞ ｿﾞ ﾀﾞ ﾁﾞ ﾂﾞ ﾃﾞ ﾄﾞ ﾊﾞ ﾋﾞ ﾌﾞ ﾍﾞ ﾎﾞ ﾊﾟ ﾋﾟ ﾌﾟ ﾍﾟ ﾎﾟ ｳﾞ ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ｦ ﾝ ｬ ｭ ｮ ｧ ｨ ｩ ｪ ｫ ｯ ﾞ ﾟ ｰ ｡ ｢ ｣ ､ ･).freeze
    def to_internal(str)
      filter(str, @@external, @@internal)
    end
    def to_external(str)
      filter(str, @@internal, @@external)
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
  end
end
