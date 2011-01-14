unless Object.const_defined?(:Encoding)
  $KCODE = 'u'
end

module Jpmobile
  module Emoticon
    GETA = 0x3013

    SJIS_TO_UNICODE = {}
    SJIS_TO_UNICODE.update(DOCOMO_SJIS_TO_UNICODE)
    SJIS_TO_UNICODE.update(AU_SJIS_TO_UNICODE)
    SJIS_TO_UNICODE.freeze
    UNICODE_TO_SJIS = SJIS_TO_UNICODE.invert.freeze

    # for au email
    SJIS_TO_EMAIL_JIS = {0x81ac => 0x222E}
    SJIS_TO_EMAIL_JIS.update(AU_SJIS_TO_EMAIL_JIS)
    SJIS_TO_EMAIL_JIS.freeze

    SJIS_REGEXP = Regexp.union(*SJIS_TO_UNICODE.keys.map{|s| Jpmobile::Util.sjis_regexp(s)})
    SOFTBANK_WEBCODE_REGEXP = Regexp.union(*([/(?!)/n]+SOFTBANK_WEBCODE_TO_UNICODE.keys.map{|x| "\x1b\x24#{x}\x0f"}))

    DOCOMO_SJIS_REGEXP      = Regexp.union(*DOCOMO_SJIS_TO_UNICODE.keys.map{|s| Jpmobile::Util.sjis_regexp(s)})
    AU_SJIS_REGEXP          = Regexp.union(*AU_SJIS_TO_UNICODE.keys.map{|s| Jpmobile::Util.sjis_regexp(s)})
    SOFTBANK_UNICODE_REGEXP = Regexp.union(*SOFTBANK_UNICODE_TO_WEBCODE.keys.map{|x| [x].pack('U')}).freeze

    EMOTICON_UNICODES = UNICODE_TO_SJIS.keys|SOFTBANK_UNICODE_TO_WEBCODE.keys.map{|k|k+0x1000}
    UTF8_REGEXP = Regexp.union(*EMOTICON_UNICODES.map{|x| [x].pack('U')}).freeze

    # for PC conversion "GETA"
    CONVERSION_TABLE_TO_PC_EMAIL = Hash[*(CONVERSION_TABLE_TO_SOFTBANK.keys|CONVERSION_TABLE_TO_DOCOMO.keys|CONVERSION_TABLE_TO_AU.keys).map{|k| [k, GETA]}.flatten]

    SOFTBANK_SJIS_REGEXP = Regexp.union(*SOFTBANK_SJIS_TO_UNICODE.keys.map{|s| Jpmobile::Util.sjis_regexp(s)}).freeze
    AU_EMAILJIS_REGEXP = Regexp.union(*AU_EMAILJIS_TO_UNICODE.keys.map{|s| Jpmobile::Util.jis_regexp(s)})
  end
end
