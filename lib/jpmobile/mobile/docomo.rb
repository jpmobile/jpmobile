# =DoCoMo携帯電話

module Jpmobile::Mobile
  # ==DoCoMo携帯電話
  class Docomo < AbstractMobile
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
  end
end
