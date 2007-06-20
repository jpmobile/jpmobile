module Jpmobile
  # 絵文字関連処理
  module Pictogram
    # 絵文字にマッチする正規表現
    # TODO: 展開して最適化する
    def self.softbank_utf8_regexp
      Regexp.union(*SOFTBANK_UNICODE_TO_WEBCODE.keys.map{|x| [x].pack('U')})
    end
    def self.softbank_webcode_regexp
      Regexp.union(*SOFTBANK_WEBCODE_TO_UNICODE.keys.map{|x| "\x1b\x24#{x}\x0f"})
    end
    #
    def self.sjis_to_unicodecr(str)
      str.gsub(SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end
    #
    def self.unicodecr_to_sjis(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        sjis = UNICODE_TO_SJIS[unicode]
        sjis ? [sjis].pack('n') : match
      end
    end
    #
    def self.unicodecr_to_utf8(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        UNICODE_TO_SJIS[unicode] ? [unicode].pack('U') : match
      end
    end
    #
    def self.utf8_to_unicodecr(str)
      str.gsub(UTF8_REGEXP) do |match|
        "&#x%04x;" % match.unpack('U').first
      end
    end
    #
    # SoftBank用変換メソッド群
    # shiftパラメータにtrueを与えるとU+F000以降にマッピングをシフトする(auとの重複を防ぐ)。
    #
    def self.softbank_webcode_cr(str, shift=false)
      s = str.clone
      s.gsub!(/\x1b\x24(.)(.+?)\x0f/) do |match|
        a = $1
        $2.split(//).map{|x| "\x1b\x24#{a}#{x}\x0f"}.join('')
      end
      s.gsub(softbank_webcode_regexp) do |match|
        unicode = SOFTBANK_WEBCODE_TO_UNICODE[match[2,2]]
        unicode += 0x1000 if shift
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end
    #
    def self.softbank_cr_webcode(str, shift=false)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        unicode -= 0x1000 if shift
        code = SOFTBANK_UNICODE_TO_WEBCODE[unicode]
        code ? "\x1b\x24#{code}\x0f" : match
      end
    end
    #
    def self.softbank_cr_utf8(str, shift=false)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        unicode -= 0x1000 if shift
        SOFTBANK_UNICODE_TO_WEBCODE[unicode] ? [unicode].pack('U') : match
      end
    end
    # 
    def self.softbank_utf8_cr(str, shift=false)
      str.gsub(softbank_utf8_regexp) do |match|
        unicode = match.unpack('U').first
        unicode += 0x1000 if shift
        "&#x%04x;" % unicode
      end
    end
  end
end
