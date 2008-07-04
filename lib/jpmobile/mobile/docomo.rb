# =DoCoMo携帯電話

module Jpmobile::Mobile
  # ==DoCoMo携帯電話
  class Docomo < AbstractMobile
    autoload :IP_ADDRESSES, 'jpmobile/mobile/z_ip_addresses_docomo'
    autoload :DISPLAY_INFO, 'jpmobile/mobile/z_display_info_docomo'

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^DoCoMo/

    # オープンiエリアがあればエリアコードを +String+ で返す。無ければ +nil+ を返す。
    def areacode
      if params["ACTN"] == "OK"
        return params["AREACODE"]
      else
        return nil
      end
    end

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__position if defined? @__position
      lat = params["lat"] || params["LAT"]
      lon = params["lon"] || params["LON"]
      geo = params["geo"] || params["GEO"]
      return @__position = nil if ( lat.nil? || lat == '' || lon.nil? || lon == '' ) 
      raise "Unsuppoted datum" if geo.downcase != "wgs84"
      pos = Jpmobile::Position.new
      raise "Unsuppoted" unless lat =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/
      pos.lat = Jpmobile::Position.dms2deg($1,$2,$3)
      raise "Unsuppoted" unless lon =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/
      pos.lon = Jpmobile::Position.dms2deg($1,$2,$3)
      return @__position = pos
    end

    # 端末製造番号があれば返す。無ければ +nil+ を返す。
    def serial_number
      case @request.env["HTTP_USER_AGENT"]
      when /ser([0-9a-zA-Z]{11})$/ # mova
        return $1
      when /ser([0-9a-zA-Z]{15});/ # FOMA
        return $1
      else
        return nil
      end
    end
    alias :ident_device :serial_number

    # FOMAカード製造番号があれば返す。無ければ +nil+ を返す。
    def icc
      @request.env['HTTP_USER_AGENT'] =~ /icc([0-9a-zA-Z]{20})\)/
      return $1
    end

    # iモードIDを返す。
    def guid
      @request.env['HTTP_X_DCMGUID']
    end

    # iモードID, FOMAカード製造番号の順で調べ、あるものを返す。なければ +nil+ を返す。
    def ident_subscriber
      guid || icc
    end

    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      @__display ||= Jpmobile::Display.new(nil,nil,
                            display_info[:browser_width],
                            display_info[:browser_height],
                            display_info[:color_p],
                            display_info[:colors])
    end

    # cookieに対応しているか？
    def supports_cookie?
      false
    end
    private
    # モデル名を返す。
    def model_name
      if @request.env["HTTP_USER_AGENT"] =~ /^DoCoMo\/2.0 (.+)\(/
        return $1
      elsif @request.env["HTTP_USER_AGENT"] =~ /^DoCoMo\/1.0\/(.+?)\//
        return $1
      end
      return nil
    end

    # 画面の情報を含むハッシュを返す。
    def display_info
      DISPLAY_INFO[model_name] || {}
    end
  end
end
