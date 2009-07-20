# -*- coding: utf-8 -*-
# =au携帯電話

require 'ipaddr'

module Jpmobile::Mobile
  # ==au携帯電話
  # CDMA 1X, CDMA 1X WINを含む。
  class Au < AbstractMobile
    autoload :IP_ADDRESSES, 'jpmobile/mobile/z_ip_addresses_au'

    # 対応するUser-Agentの正規表現
    # User-Agent文字列中に "UP.Browser" を含むVodafoneの端末があるので注意が必要
    USER_AGENT_REGEXP = /^(?:KDDI|UP.Browser\/.+?)-(.+?) /
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /^.+@ezweb\.ne\.jp$/
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

    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      return @__display if @__display

      p_w = p_h = col_p = cols = nil
      if r = @request.env['HTTP_X_UP_DEVCAP_SCREENPIXELS']
        p_w, p_h = r.split(/,/,2).map {|x| x.to_i}
      end
      if r = @request.env['HTTP_X_UP_DEVCAP_ISCOLOR']
        col_p = (r == '1')
      end
      if r = @request.env['HTTP_X_UP_DEVCAP_SCREENDEPTH']
        a = r.split(/,/)
        cols = 2 ** a[0].to_i
      end
      @__display = Jpmobile::Display.new(p_w, p_h, nil, nil, col_p, cols)
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
  end
end
