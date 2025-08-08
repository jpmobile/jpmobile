#= 位置情報

# Rack 化にあわせて gem を見るように
begin
  require 'openssl'
  require 'geokit'
rescue LoadError
end

module Jpmobile
  # 位置情報
  class Position
    if Object.const_defined?(:GeoKit)
      # GeoKitが読み込まれている場合はMappableにする
      include ::GeoKit::Mappable

      def self.acts_as_mappable
      end

      def self.distance_column_name
      end

      def self.lat_column_name
        :lat
      end

      def self.lng_column_name
        :lng
      end
    end
    # 度分秒を度に変換する。
    def self.dms2deg(d, m, s)
      d.to_i + (m.to_i.to_f / 60) + (s.to_f / 3600)
    end

    def initialize
      @lat = nil
      @lon = nil
      @options = {}
    end

    # 日本測地系から世界測地系に変換する。
    def tokyo2wgs84!
      @lat, @lon = DatumConv.tky2jgd(@lat, @lon)
    end

    # 文字列で緯度経度を返す。
    def to_s
      '%s%f%s%f' %
        [
          (@lat > 0) ? 'N' : 'S',
          @lat, (@lon > 0) ? 'E' : 'W',
          @lon
        ]
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
      self.lon
    end

    # 経度を設定
    def lng=(l)
      self.lon = l
    end

    # 緯度と経度が一致している場合に +true+
    def ==(other)
      other.lat == self.lat && other.lon == self.lon
    end

    # その他の情報
    attr_accessor :options
  end
end
