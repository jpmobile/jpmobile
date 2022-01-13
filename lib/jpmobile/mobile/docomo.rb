# =DoCoMo携帯電話

module Jpmobile::Mobile
  # ==DoCoMo携帯電話
  class Docomo < AbstractMobile
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^DoCoMo/.freeze
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /.+@docomo\.ne\.jp/.freeze
    # メールのデフォルトのcharset
    MAIL_CHARSET = 'Shift_JIS'.freeze
    # テキスト部分の content-transfer-encoding
    MAIL_CONTENT_TRANSFER_ENCODING = '8bit'.freeze

    # オープンiエリアがあればエリアコードを +String+ で返す。無ければ +nil+ を返す。
    def areacode
      if params['ACTN'] == 'OK'
        params['AREACODE']
      else
        nil
      end
    end

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__position if defined? @__position

      lat = params['lat'] || params['LAT']
      lon = params['lon'] || params['LON']
      geo = params['geo'] || params['GEO']
      return @__position = nil if lat.nil? || lat == '' || lon.nil? || lon == ''
      raise 'Unsuppoted datum' unless geo.casecmp('wgs84')

      pos = Jpmobile::Position.new
      raise 'Unsuppoted' unless lat =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/

      pos.lat = Jpmobile::Position.dms2deg(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3))
      raise 'Unsuppoted' unless lon =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/

      pos.lon = Jpmobile::Position.dms2deg(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3))
      @__position = pos
    end

    # 端末製造番号があれば返す。無ければ +nil+ を返す。
    def serial_number
      case @env['HTTP_USER_AGENT']
      when /ser([0-9a-zA-Z]{11})$/, # mova
           /ser([0-9a-zA-Z]{15});/ # FOMA
        Regexp.last_match(1)
      else
        nil
      end
    end
    alias_method :ident_device, :serial_number

    # FOMAカード製造番号があれば返す。無ければ +nil+ を返す。
    def icc
      @env['HTTP_USER_AGENT'] =~ /icc([0-9a-zA-Z]{20})\)/
      Regexp.last_match(1)
    end

    # iモードIDを返す。
    def guid
      @env['HTTP_X_DCMGUID']
    end

    # iモードID, FOMAカード製造番号の順で調べ、あるものを返す。なければ +nil+ を返す。
    def ident_subscriber
      guid || icc
    end

    # cookieに対応しているか？
    def supports_cookie?
      imode_browser_version != '1.0'
    end

    # 文字コード変換
    def to_internal(str)
      # 絵文字を数値参照に変換
      str = Jpmobile::Emoticon.external_to_unicodecr_docomo(Jpmobile::Util.sjis(str))
      # 文字コードを UTF-8 に変換
      str = Jpmobile::Util.sjis_to_utf8(str)
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon.unicodecr_to_utf8(str)
    end

    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      # 文字コードを Shift_JIS に変換
      if [nil, 'text/html', 'application/xhtml+xml'].include?(content_type)
        str = Jpmobile::Util.utf8_to_sjis(str)
        charset = default_charset unless str.empty?
      end
      # 数値参照を絵文字コードに変換
      str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_DOCOMO, true)

      [str, charset]
    end

    def default_charset
      'Shift_JIS'
    end

    # メール送信用
    def to_mail_body(str)
      to_external(str, nil, nil).first
    end

    def to_mail_encoding(str)
      to_external(str, nil, nil).first
    end

    def to_mail_internal(str, charset)
      if Jpmobile::Util.shift_jis?(str) || Jpmobile::Util.ascii_8bit?(str) || (charset == mail_charset)
        # 絵文字を数値参照に変換
        str = Jpmobile::Emoticon.external_to_unicodecr_docomo(Jpmobile::Util.sjis(str))
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

    # i-mode ブラウザのバージョンを返す。
    # http://labs.unoh.net/2009/07/i_20.html
    def imode_browser_version
      case @request.env['HTTP_USER_AGENT']
      when %r{^DoCoMo/1.0/}
        ver = '1.0'
      when %r{^DoCoMo/2.0 }
        @request.env['HTTP_USER_AGENT'] =~ / (\w+)\(c(\d+);/
        model = Regexp.last_match(1)
        cache_size = Regexp.last_match(2).to_i

        ver = if cache_size >= 500
                (%w[P03B P05B L01B].member?(model) ? '2.0LE' : '2.0')
              else
                '1.0'
              end
      else
        # DoCoMo/3.0以降等は、とりあえず非v1.0扱い
        ver = '2.0'
      end

      ver
    end

    # モデル名を返す。
    def model_name
      case @env['HTTP_USER_AGENT']
      when %r{^DoCoMo/2.0 (.+)\(},
           %r{^DoCoMo/1.0/(.+?)/}
        Regexp.last_match(1)
      else
        nil
      end
    end
  end
end
