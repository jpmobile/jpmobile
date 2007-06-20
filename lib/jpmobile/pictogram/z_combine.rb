module Jpmobile
  module Pictogram
    SJIS_TO_UNICODE = {}
    SJIS_TO_UNICODE.update(DOCOMO_SJIS_TO_UNICODE)
    SJIS_TO_UNICODE.update(AU_SJIS_TO_UNICODE)
    SJIS_TO_UNICODE.freeze
    UNICODE_TO_SJIS = SJIS_TO_UNICODE.invert.freeze

    SJIS_REGEXP = Regexp.union(*SJIS_TO_UNICODE.keys.map{|x| [x].pack('n')}).freeze
    UTF8_REGEXP = Regexp.union(*UNICODE_TO_SJIS.keys.map{|x| [x].pack('U')}).freeze
  end
end
