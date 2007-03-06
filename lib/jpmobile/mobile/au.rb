# =au携帯電話

require 'ipaddr'

module Jpmobile::Mobile
  # ==au携帯電話
  # CDMA 1X, CDMA 1X WINを含む。
  class Au < AbstractMobile
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^KDDI-/

    # EZ番号(サブスクライバID)があれば返す。無ければ +nil+ を返す。
    def subno
      @request.env["HTTP_X_UP_SUBNO"]
    end
    alias :ident :subno
    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return nil if params["lat"].blank? || params["lon"].blank?
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
        return nil
      end
      if params["datum"] == "1"
        # ただし、params["datum"]=="tokyo"のとき(簡易位置情報)のときは、
        # 実際にはWGS84系のデータが渡ってくる
        # http://www.au.kddi.com/ezfactory/tec/spec/eznavi.html
        l.tokyo2wgs84!
      end
      return l
    end
    # ブラウザ画面の幅を返す。
    def browser_width
      if r = @request.env['HTTP_X_UP_DEVCAP_SCREENPIXELS']
        r.split(/,/,2)[0].to_i
      else
        nil
      end
    end
    # ブラウザ画面の高さを返す。
    def browser_height
      if r = @request.env['HTTP_X_UP_DEVCAP_SCREENPIXELS']
        r.split(/,/,2)[1].to_i
      else
        nil
      end
    end
    # カラー端末の場合は +true+、白黒端末の場合は +false+、不明の場合は +nil+ を返す。
    def display_color?
      if r = @request.env['HTTP_X_UP_DEVCAP_ISCOLOR']
        r == '1'
      else
        nil
      end
    end
    # 端末の色数(白黒端末の場合は階調数)を返す。
    def display_depth
      if r = @request.env['HTTP_X_UP_DEVCAP_SCREENDEPTH']
        a = r.split(/,/)
        2 ** a[0].to_i
      else
        nil
      end
    end
  end
end
