# -*- coding: utf-8 -*-
# =au携帯電話

module Jpmobile::Mobile
  # ==au携帯電話
  # CDMA 1X, CDMA 1X WINを含む。
  class Au < AbstractMobile
    # 対応するUser-Agentの正規表現
    # User-Agent文字列中に "UP.Browser" を含むVodafoneの端末があるので注意が必要
    USER_AGENT_REGEXP = /^(?:KDDI|UP.Browser\/.+?)-(.+?) /
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /.+@ezweb\.ne\.jp/
    # 簡易位置情報取得に対応していないデバイスID
    # http://www.au.kddi.com/ezfactory/tec/spec/eznavi.html
    LOCATION_UNSUPPORTED_DEVICE_ID = ["PT21", "TS25", "KCTE", "TST9", "KCU1", "SYT5", "KCTD", "TST8", "TST7", "KCTC", "SYT4", "KCTB", "KCTA", "TST6", "KCT9", "TST5", "TST4", "KCT8", "SYT3", "KCT7", "MIT1", "MAT3", "KCT6", "TST3", "KCT5", "KCT4", "SYT2", "MAT1", "MAT2", "TST2", "KCT3", "KCT2", "KCT1", "TST1", "SYT1"]
    # GPS取得に対応していないデバイスID
    GPS_UNSUPPORTED_DEVICE_ID = ["PT21", "KC26", "SN28", "SN26", "KC23", "SA28", "TS25", "SA25", "SA24", "SN23", "ST14", "KC15", "SN22", "KC14", "ST13", "SN17", "SY15", "CA14", "HI14", "TS14", "KC13", "SN15", "SN16", "SY14", "ST12", "TS13", "CA13", "MA13", "HI13", "SN13", "SY13", "SN12", "SN14", "ST11", "DN11", "SY12", "KCTE", "TST9", "KCU1", "SYT5", "KCTD", "TST8", "TST7", "KCTC", "SYT4", "KCTB", "KCTA", "TST6", "KCT9", "TST5", "TST4", "KCT8", "SYT3", "KCT7", "MIT1", "MAT3", "KCT6", "TST3", "KCT5", "KCT4", "SYT2", "MAT1", "MAT2", "TST2", "KCT3", "KCT2", "KCT1", "TST1", "SYT1"]

    # EZ番号(サブスクライバID)があれば返す。無ければ +nil+ を返す。
    def subno
      @request.env["HTTP_X_UP_SUBNO"]
    end
    alias :ident_subscriber :subno

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__posotion if defined? @__posotion
      return @__posotion = nil if ( params["lat"].nil? || params['lat'] == '' || params["lon"].nil? || params["lon"] == '' )
      l = Jpmobile::Position.new
      l.options = params.reject {|x,v| !["ver", "datum", "unit", "lat", "lon", "alt", "time", "smaj", "smin", "vert", "majaa", "fm"].include?(x) }
      case params["unit"]
      when "1"
        l.lat = params["lat"].to_f
        l.lon = params["lon"].to_f
      when "0", "dms"
        raise "Invalid dms form" unless params["lat"] =~ /^([+-]?\d+)\.(\d+)\.(\d+\.\d+)$/
        l.lat = Jpmobile::Position.dms2deg($1,$2,$3)
        raise "Invalid dms form" unless params["lon"] =~ /^([+-]?\d+)\.(\d+)\.(\d+\.\d+)$/
        l.lon = Jpmobile::Position.dms2deg($1,$2,$3)
      else
        return @__posotion = nil
      end
      if params["datum"] == "1"
        # ただし、params["datum"]=="tokyo"のとき(簡易位置情報)のときは、
        # 実際にはWGS84系のデータが渡ってくる
        # http://www.au.kddi.com/ezfactory/tec/spec/eznavi.html
        l.tokyo2wgs84!
      end
      return @__posotion = l
    end

    # デバイスIDを返す
    def device_id
      if @request.env['HTTP_USER_AGENT'] =~ USER_AGENT_REGEXP
        return $1
      else
        nil
      end
    end

    # 簡易位置情報取得に対応している場合は +true+ を返す。
    def supports_location?
      ! LOCATION_UNSUPPORTED_DEVICE_ID.include?(device_id)
    end

    # GPS位置情報取得に対応している場合は +true+ を返す。
    def supports_gps?
      ! GPS_UNSUPPORTED_DEVICE_ID.include?(device_id)
    end

    # cookieに対応しているか？
    def supports_cookie?
      protocol = @request.respond_to?(:scheme) ? @request.scheme : @request.protocol rescue "none"
      if protocol =~ /\Ahttps/
        false
      else
        true
      end
    end

    # 文字コード変換
    def to_internal(str)
      # 絵文字を数値参照に変換
      str = Jpmobile::Emoticon.external_to_unicodecr_au(Jpmobile::Util.sjis(str))
      # 文字コードを UTF-8 に変換
      str = Jpmobile::Util.sjis_to_utf8(str)
      # 数値参照を UTF-8 に変換
      Jpmobile::Emoticon::unicodecr_to_utf8(str)
    end
    def to_external(str, content_type, charset)
      # UTF-8を数値参照に
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      # 文字コードを Shift_JIS に変換
      if [nil, "text/html", "application/xhtml+xml"].include?(content_type)
        str = Jpmobile::Util.utf8_to_sjis(str)
        charset = default_charset unless str.empty?
      end
      # 数値参照を絵文字コードに変換
      str = Jpmobile::Emoticon.unicodecr_to_external(str, Jpmobile::Emoticon::CONVERSION_TABLE_TO_AU, true)

      [str, charset]
    end
    def default_charset
      "Shift_JIS"
    end

    # メール送信用
    def to_mail_body(str)
      to_mail_encoding(str)
    end

    def to_mail_internal(str, charset)
      if Jpmobile::Util.jis?(str) or Jpmobile::Util.ascii_8bit?(str) or charset == mail_charset
        # 絵文字を数値参照に変換
        str = Jpmobile::Emoticon.external_to_unicodecr_au_mail(Jpmobile::Util.jis(str))
        str = Jpmobile::Util.jis_to_utf8(Jpmobile::Util.jis_win(str))
      end
      str
    end

    def decoratable?
      true
    end

    private
    def to_mail_encoding(str)
      str = Jpmobile::Emoticon.utf8_to_unicodecr(str)
      str = Jpmobile::Util.utf8_to_jis(str)
      Jpmobile::Util.jis(Jpmobile::Emoticon.unicodecr_to_au_email(str))
    end
  end
end
