# =SoftBank携帯電話
# Vodafoneを含む
module Jpmobile::Mobile
  # ==Softbank携帯電話
  # Vodafoneのスーパクラス。
  class Softbank < AbstractMobile
    # 対応するuser-agentの正規表現
    USER_AGENT_REGEXP = /^(?:SoftBank|Semulator)/
    # 対応するメールアドレスの正規表現　ディズニーモバイル対応
    MAIL_ADDRESS_REGEXP = /.+@(?:softbank\.ne\.jp|disney\.ne\.jp)/
    # メールのデフォルトのcharset
    MAIL_CHARSET = 'Shift_JIS'.freeze
    # テキスト部分の content-transfer-encoding
    MAIL_CONTENT_TRANSFER_ENCODING = '8bit'.freeze

    TARGET_PARAMS = ['pos', 'geo', 'x-acr'].freeze

    # 製造番号を返す。無ければ +nil+ を返す。
    def serial_number
      @request.env['HTTP_USER_AGENT'] =~ /SN(.+?) /
      Regexp.last_match(1)
    end
    alias_method :ident_device, :serial_number

    # UIDを返す。
    def x_jphone_uid
      @request.env['HTTP_X_JPHONE_UID']
    end
    alias_method :ident_subscriber, :x_jphone_uid

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__position if defined? @__position
      return @__position = nil unless params['pos'] =~ /^([NS])(\d+)\.(\d+)\.(\d+\.\d+)([WE])(\d+)\.(\d+)\.(\d+\.\d+)$/

      raise 'Unsupported datum' if params['geo'] != 'wgs84'

      l = Jpmobile::Position.new
      l.lat = ((Regexp.last_match(1) == 'N') ? 1 : -1) * Jpmobile::Position.dms2deg(Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4))
      l.lon = ((Regexp.last_match(5) == 'E') ? 1 : -1) * Jpmobile::Position.dms2deg(Regexp.last_match(6), Regexp.last_match(7), Regexp.last_match(8))
      l.options = params.select {|x, _| TARGET_PARAMS.include?(x) }

      @__position = l
    end

    # cookieに対応しているか？
    def supports_cookie?
      true
    end

    # 文字コード変換
    def to_internal(str)
      # 絵文字を数値参照に変換
      str = Jpmobile::Emoticon.external_to_unicodecr_softbank(Jpmobile::Util.utf8(str))
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon.unicodecr_to_utf8(str)
    end

    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      # 数値参照を絵文字コードに変換
      str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_SOFTBANK, false)

      [str, charset]
    end

    # メール送信用
    def to_mail_body(str)
      to_mail_encoding(str)
    end

    def to_mail_internal(str, charset)
      # 絵文字を数値参照に変換
      if Jpmobile::Util.utf8?(str) || (charset == 'UTF-8')
        # UTF-8
        str = Jpmobile::Emoticon.external_to_unicodecr_softbank(Jpmobile::Util.utf8(str))
      elsif Jpmobile::Util.shift_jis?(str) || Jpmobile::Util.ascii_8bit?(str) || (charset == mail_charset)
        # Shift_JIS
        str = Jpmobile::Emoticon.external_to_unicodecr_softbank_sjis(Jpmobile::Util.sjis(str))
      end

      str
    end

    def to_mail_body_encoded?(str)
      Jpmobile::Util.shift_jis?(str)
    end

    def decoratable?
      true
    end

    def require_related_part?
      true
    end

    private

    def to_mail_encoding(str)
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      str = Jpmobile::Util.utf8_to_sjis(str)
      Jpmobile::Emoticon.unicodecr_to_softbank_email(str)
    end
  end
end
