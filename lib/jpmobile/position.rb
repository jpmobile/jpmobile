#= 位置情報

# plugins/以下にgeokitがインストールされている場合は読み込む
begin
  require RAILS_ROOT + '/vendor/plugins/geokit/lib/geo_kit/mappable'
rescue MissingSourceFile, NameError
end

module Jpmobile
  # 位置情報
  class Position
    # GeoKitが読み込まれている場合はMappableにする
    include ::GeoKit::Mappable if Object.const_defined?("GeoKit")
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

    # 緯度経度をカンマ区切りで返す
    def ll
      "#{lat},#{lng}"
    end

    # 緯度
    attr_accessor :lat

    # 経度
    attr_accessor :lon

    # 経度
    def lng
      lon
    end

    # 経度を設定
    def lng=(l)
      lon = l
    end

    # 緯度と経度が一致している場合に +true+
    def ==(x)
      x.lat == lat && x.lon == lon
    end

    # その他の情報
    attr_accessor :options
  end
end
