# =Willcom携帯電話
# DDI-POCKETを含む。

module Jpmobile::Mobile
  # ==Willcom携帯電話
  # Ddipocketのスーパクラス。
  class Willcom < AbstractMobile
    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return nil if params["pos"].blank?
      raise "unsupported format" unless params["pos"] =~ /^N(\d\d)\.(\d\d)\.(\d\d\.\d\d\d)E(\d\d\d)\.(\d\d)\.(\d\d\.\d\d\d)$/
      pos = Jpmobile::Position.new
      pos.lat = Jpmobile::Position.dms2deg($1,$2,$3)
      pos.lon = Jpmobile::Position.dms2deg($4,$5,$6)
      pos.tokyo2wgs84!
      return pos
    end
  end
  # ==DDI-POCKET
  # スーパクラスはWillcom。
  class Ddipocket < Willcom; end
end
