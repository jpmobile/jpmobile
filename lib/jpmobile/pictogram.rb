module Jpmobile
  # 絵文字関連処理
  module Pictogram
    # DoCoMo絵文字にマッチする正規表現
    DOCOMO_SJIS_REGEXP = /\xf8[\x9f-\xfc]|
                           \xf9[\x40-\x49\x50-\x52\x55-\x57\x5b-\x5e\x72-\x7e\x80-\xfc]/x.freeze
    DOCOMO_UTF8_REGEXP = /\xee(?:\x98[\xbe-\xbf]|
                                         \x99[\x80-\xbf]|
                                         \x9a[\x80-\xa5\xac-\xae\xb1-\xb3\xb7-\xba]|
                                         \x9b[\x8e-\xbf]|
                                         \x9c[\x80-\xbf]|
                                         \x9d[\x80-\x97])/x.freeze
    # au絵文字にマッチする正規表現
    # TODO: 展開して最適化する
    def self.au_sjis_regexp
      Regexp.union(*AU_SJIS_TO_UNICODE.keys.map{|x| [x].pack('n')})
    end
    def self.au_utf8_regexp
      Regexp.union(*AU_UNICODE_TO_SJIS.keys.map{|x| [x].pack('U')})
    end
   # DoCoMo Shift_JISバイナリ絵文字 を DoCoMo Unicode絵文字文字参照 に変換
    def self.docomo_sjis_cr(str)
      str.gsub(DOCOMO_SJIS_REGEXP) do |match|
        sjis = match.unpack('n').first
        unicode = DOCOMO_SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end
    # DoCoMo Unicode絵文字文字参照 を DoCoMo Shift_JISバイナリ絵文字 に変換
    def self.docomo_cr_sjis(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        sjis = DOCOMO_UNICODE_TO_SJIS[unicode]
        sjis ? [sjis].pack('n') : match
      end
    end
    # DoCoMo Unicode絵文字文字参照 を DoCoMo UTF-8絵文字バイナリ に置換
    def self.docomo_cr_utf8(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        DOCOMO_UNICODE_TO_SJIS[unicode] ? [unicode].pack('U') : match
      end
    end
    # DoCoMo UTF-8絵文字バイナリ を DoCoMo Unicode絵文字文字参照 に置換
    def self.docomo_utf8_cr(str)
      str.gsub(DOCOMO_UTF8_REGEXP) do |match|
        "&#x%04x;" % match.unpack('U').first
      end
    end
    # au Shift_JISバイナリ絵文字 を au Unicode絵文字文字参照 に変換
    def self.au_sjis_cr(str)
      str.gsub(au_sjis_regexp) do |match|
        sjis = match.unpack('n').first
        unicode = AU_SJIS_TO_UNICODE[sjis]
        unicode ? ("&#x%04x;"%unicode) : match
      end
    end
    # au Unicode絵文字文字参照 を au Shift_JISバイナリ絵文字 に変換
    def self.au_cr_sjis(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        sjis = AU_UNICODE_TO_SJIS[unicode]
        sjis ? [sjis].pack('n') : match
      end
    end
    # au Unicode絵文字文字参照 を au UTF-8絵文字バイナリ に置換
    def self.au_cr_utf8(str)
      str.gsub(/&#x([0-9a-f]{4});/i) do |match|
        unicode = $1.scanf("%x").first
        AU_UNICODE_TO_SJIS[unicode] ? [unicode].pack('U') : match
      end
    end
    # au UTF-8絵文字バイナリ を au Unicode絵文字文字参照 に置換
    def self.au_utf8_cr(str)
      str.gsub(au_utf8_regexp) do |match|
        "&#x%04x;" % match.unpack('U').first
      end
    end
  end
end
