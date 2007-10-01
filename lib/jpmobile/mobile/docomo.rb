# =DoCoMo携帯電話

module Jpmobile::Mobile
  # ==DoCoMo携帯電話
  class Docomo < AbstractMobile
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
      return nil if params["lat"].blank? || params["lon"].blank?
      raise "Unsuppoted datum" if params["geo"].downcase != "wgs84"
      pos = Jpmobile::Position.new
      raise "Unsuppoted" unless params["lat"] =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/
      pos.lat = Jpmobile::Position.dms2deg($1,$2,$3)
      raise "Unsuppoted" unless params["lon"] =~ /^([+-]\d+)\.(\d+)\.(\d+\.\d+)/
      pos.lon = Jpmobile::Position.dms2deg($1,$2,$3)
      return pos
    end

    # 端末製造番号があれば返す。無ければ +nil+ を返す。
    def serial_number
      case @request.user_agent
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
      @request.user_agent =~ /icc([0-9a-zA-Z]{20})\)/
      return $1
    end
    alias :ident_subscriber :icc

    # 画面情報を +Display+ クラスのインスタンスで返す。
    def display
      Jpmobile::Display.new(nil,nil,
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
      if @request.user_agent =~ /^DoCoMo\/2.0 (.+)\(/
        return $1
      elsif @request.user_agent =~ /^DoCoMo\/1.0\/(.+?)\//
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
