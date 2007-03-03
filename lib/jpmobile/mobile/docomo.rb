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
    # FOMAカード製造番号があれば返す。無ければ +nil+ を返す。
    def icc
      @request.user_agent =~ /icc([0-9a-zA-Z]{20})\)/
      return $1
    end
    # Docomo#icc、Docomo#serial_number の順で有効なものが有れば返す。無ければ +nil+ を返す。
    def ident
      icc || serial_number
    end
    # ブラウザ画面の幅を返す。
    def browser_width
      display_info[:browser_width]
    end
    # ブラウザ画面の高さを返す。
    def browser_height
      display_info[:browser_height]
    end
    # カラー端末の場合は +true+、白黒端末の場合は +false+ を返す。
    def display_color?
      display_info[:color_p]
    end
    # 端末の色数(白黒端末の場合は階調数)を返す。
    def display_depth
      display_info[:depth]
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
