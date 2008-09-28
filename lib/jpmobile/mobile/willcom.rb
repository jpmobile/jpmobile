# =Willcom携帯電話
# DDI-POCKETを含む。

module Jpmobile::Mobile
  # ==Willcom携帯電話
  # Ddipocketのスーパクラス。
  class Willcom < AbstractMobile
    autoload :IP_ADDRESSES, 'jpmobile/mobile/z_ip_addresses_willcom'

    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^Mozilla\/3.0\(WILLCOM/
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /^.+@(.+\.)?pdx\.ne\.jp$/

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__position if defined? @__position
      return @__position = nil if ( params["pos"].nil? || params['pos'] == '' )
      raise "unsupported format" unless params["pos"] =~ /^N(\d\d)\.(\d\d)\.(\d\d\.\d\d\d)E(\d\d\d)\.(\d\d)\.(\d\d\.\d\d\d)$/
      pos = Jpmobile::Position.new
      pos.lat = Jpmobile::Position.dms2deg($1,$2,$3)
      pos.lon = Jpmobile::Position.dms2deg($4,$5,$6)
      pos.tokyo2wgs84!
      return @__position = pos
    end
    # cookieに対応しているか？
    def supports_cookie?
      true
    end
  end
  # ==DDI-POCKET
  # スーパクラスはWillcom。
  class Ddipocket < Willcom
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = /^Mozilla\/3.0\(DDIPOCKET/

    MAIL_ADDRESS_REGEXP = nil # DdipocketはEmail判定だとWillcomと判定させたい
  end
end
