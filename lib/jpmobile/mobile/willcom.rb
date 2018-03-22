# =Willcom携帯電話
module Jpmobile::Mobile
  # ==Willcom携帯電話
  # Ddipocketのスーパクラス。
  class Willcom < AbstractMobile
    # 対応するUser-Agentの正規表現
    USER_AGENT_REGEXP = %r{^Mozilla/3.0\(WILLCOM}
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /.+@((.+\.)?pdx\.ne\.jp|willcom\.com)/

    # 位置情報があれば Position のインスタンスを返す。無ければ +nil+ を返す。
    def position
      return @__position if defined? @__position
      return @__position = nil if params['pos'].nil? || params['pos'] == ''
      raise 'unsupported format' unless params['pos'] =~ /^N(\d\d)\.(\d\d)\.(\d\d\.\d\d\d)E(\d\d\d)\.(\d\d)\.(\d\d\.\d\d\d)$/

      pos = Jpmobile::Position.new
      pos.lat = Jpmobile::Position.dms2deg(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3))
      pos.lon = Jpmobile::Position.dms2deg(Regexp.last_match(4), Regexp.last_match(5), Regexp.last_match(6))
      pos.tokyo2wgs84!
      @__position = pos
    end

    # cookieに対応しているか？
    def supports_cookie?
      true
    end
  end
end
