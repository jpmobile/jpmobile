#= 位置情報

module Jpmobile
  # 位置情報
  class Position
    def initialize
      @lat = nil
      @lon = nil
      @options = {}
    end
    # 度分秒を度に変換する。
    def self.dms2deg(d,m,s)
      return d.to_i + m.to_i.to_f/60 + s.to_f/3600
    end
    # 日本測地系から世界測地系に変換する。
    def tokyo2wgs84!
      @lat, @lon = DatumConv.tky2jgd(@lat,@lon)
    end
    # 文字列で緯度経度を返す。
    def to_s
      sprintf("%s%f%s%f", @lat>0 ? 'N' : 'S', @lat, @lon>0 ? 'E' : 'W', @lon)
    end

    # 緯度
    attr_accessor :lat

    # 経度
    attr_accessor :lon

    # その他の情報
    attr_accessor :options
  end
end
