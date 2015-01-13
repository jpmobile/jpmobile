# -*- coding: utf-8 -*-
require 'tempfile'
require 'nkf'

module Jpmobile
  module Util
    # SJIS   = "Shift_JIS"
    SJIS   = "Windows-31J"
    UTF8   = "UTF-8"
    JIS    = "ISO-2022-JP"
    JIS_WIN = "CP50220"
    BINARY = "ASCII-8BIT"

    WAVE_DASH = [0x301c].pack("U")
    FULLWIDTH_TILDE = [0xff5e].pack("U")

    OVERLINE = [0x203e].pack("U")
    FULLWIDTH_MACRON = [0xffe3].pack("U")

    EM_DASH = [0x2014].pack("U")
    HORIZONTAL_BAR = [0x2015].pack("U")

    MINUS_SIGN = [0x2212].pack("U")
    FULLWIDTH_HYPHEN_MINUS = [0xFF0D].pack("U")

    module_function
    def deep_apply(obj, &proc)
      case obj
      when Hash
        obj.each_pair do |key, value|
          obj[key] = deep_apply(value, &proc)
        end
      when Array
        obj.collect!{|value| deep_apply(value, &proc)}
      when String
        obj = obj.to_param if obj.respond_to?(:to_param)
        proc.call(obj)
      else
        # NilClass, TrueClass, FalseClass, Tempfile, StringIO, etc...
        return obj
      end
    end

    def deep_convert(obj, &proc)
      case obj
      when Hash
        new_obj = {}
        obj.each_pair do |key, value|
          new_obj[deep_convert(key.dup, &proc)] = deep_convert(value, &proc)
        end
        new_obj
      when Array
        new_obj = obj.map do |value|
          deep_convert(value, &proc)
        end
      when Symbol
        new_obj = proc.call(obj.to_s).to_sym
      when String
        obj = obj.to_param if obj.respond_to?(:to_param)
        new_obj = proc.call(obj)
      else
        # NilClass, TrueClass, FalseClass, Tempfile, StringIO, etc...
        new_obj = obj
      end

      new_obj
    end

    def sjis(str)
      if str.respond_to?(:force_encoding) and !shift_jis?(str)
        str.force_encoding(SJIS)
      end
      str
    end

    def utf8(str)
      if str.respond_to?(:force_encoding) and !utf8?(str)
        str.force_encoding(UTF8)
      end
      str
    end

    def jis(str)
      if str.respond_to?(:force_encoding) and !jis?(str)
        str.force_encoding(JIS)
      end
      str
    end

    def jis_win(str)
      if str.respond_to?(:force_encoding) and !jis?(str)
        str.force_encoding(JIS_WIN)
      end
      str
    end

    def ascii_8bit(str)
      if str.respond_to?(:force_encoding) and !ascii_8bit?(str)
        str.force_encoding(BINARY)
      end
      str
    end

    def ascii_compatible!(str)
      if str.respond_to?(:encoding) and !str.encoding.ascii_compatible?
        str.force_encoding(BINARY)
      end
      str
    end

    def utf8_to_sjis(utf8_str)
      # 波ダッシュ対策
      utf8_str = wavedash_to_fullwidth_tilde(utf8_str)
      # オーバーライン対策(不可逆的)
      utf8_str = overline_to_fullwidth_macron(utf8_str)
      # ダッシュ対策（不可逆的）
      utf8_str = emdash_to_horizontal_bar(utf8_str)
      # マイナス対策（不可逆的）
      utf8_str = minus_sign_to_fullwidth_hyphen_minus(utf8_str)

      if utf8_str.respond_to?(:encode)
        utf8_str.
        gsub(/(\r\n|\r|\n)/, "\r\n").
        encode(SJIS, :undef => :replace, :replace => '?')
      else
        NKF.nkf("-m0 -x -W --oc=cp932 --fb-subchar=63", utf8_str).gsub(/(\r\n|\r|\n)/, "\r\n")
      end
    end

    def sjis_to_utf8(sjis_str)
      utf8_str = if sjis_str.respond_to?(:encode)
                   sjis_str.encode("UTF-8", :universal_newline => true)
                 else
                   NKF.nkf("-m0 -x -w --ic=cp932", sjis_str).gsub(/\r\n?/, "\n")
                 end

      # 波ダッシュ対策
      fullwidth_tilde_to_wavedash(utf8_str)
    end

    def utf8_to_jis(utf8_str)
      # 波ダッシュ対策
      utf8_str = fullwidth_tilde_to_wavedash(utf8_str)

      if utf8_str.respond_to?(:encode)
        utf8_str.
        gsub(/(\r\n|\r|\n)/, "\r\n").
        encode(JIS, :undef => :replace, :replace => '?')
      else
        NKF.nkf("-m0 -x -Wj --fb-subchar=63", utf8_str).gsub(/(\r\n|\r|\n)/, "\r\n")
      end
    end

    def jis_to_utf8(jis_str)
      if jis_str.respond_to?(:encode)
        jis_str.encode(UTF8, :universal_newline => true)
      else
        NKF.nkf("-m0 -x -Jw", jis_str).gsub(/\r\n?/, "\n")
      end
    end

    def regexp_utf8_to_sjis(utf8_str)
      Regexp.compile(Regexp.escape(utf8_to_sjis(utf8_str)))
    end

    def regexp_to_sjis(sjis_str)
      Regexp.compile(Regexp.escape(sjis(sjis_str)))
    end

    def hash_to_utf8(hash)
      new_hash = {}
      hash.each do |keu, value|
        new_hash[utf8(key)] = utf8(value)
      end
    end

    def sjis_regexp(sjis)
      sjis_str = if sjis.kind_of?(Numeric)
                   [sjis].pack('n')
                 else
                   sjis
                 end

      Regexp.compile(Regexp.escape(sjis_str.force_encoding(SJIS)))
    end

    def jis_regexp(jis)
      jis_str = jis.kind_of?(Numeric) ? [jis].pack('n') : jis

      Regexp.compile(Regexp.escape(jis_str.force_encoding(BINARY)))
    end

    def jis_string_regexp
      Regexp.compile(Regexp.escape(ascii_8bit("\x1b\x24\x42")) + "(.+?)" + Regexp.escape(ascii_8bit("\x1b\x28\x42")))
    end

    def encode(str, charset)
      if (charset.nil? or charset == "" or str.nil? or str == "")
        str
      elsif utf8?(str) and charset.match(/iso-2022-jp/i)
        utf8_to_jis(str)
      elsif utf8?(str) and charset.match(/shift_jis/i)
        utf8_to_sjis(str)
      elsif utf8?(str) and charset.match(/utf-8/i)
        str
      else
        str.encode(charset)
      end
    end

    def wavedash_to_fullwidth_tilde(utf8_str)
      utf8_str.gsub(WAVE_DASH, FULLWIDTH_TILDE)
    end

    def fullwidth_tilde_to_wavedash(utf8_str)
      utf8_str.gsub(FULLWIDTH_TILDE, WAVE_DASH)
    end

    def overline_to_fullwidth_macron(utf8_str)
      utf8_str.gsub(OVERLINE, FULLWIDTH_MACRON)
    end

    def fullwidth_macron_to_overline(utf8_str)
      utf8_str.gsub(FULLWIDTH_MACRON, OVERLINE)
    end

    def emdash_to_horizontal_bar(utf8_str)
      utf8_str.gsub(EM_DASH, HORIZONTAL_BAR)
    end

    def minus_sign_to_fullwidth_hyphen_minus(utf8_str)
      utf8_str.gsub(MINUS_SIGN, FULLWIDTH_HYPHEN_MINUS)
    end

    def fullwidth_hyphen_minus_to_minus_sign(utf8_str)
      utf8_str.gsub(FULLWIDTH_HYPHEN_MINUS, MINUS_SIGN)
    end

    def force_encode(str, from, to)
      s = str.dup
      return str if detect_encoding(str) == to

      to = SJIS if to =~ /shift_jis/i

      to_enc = ::Encoding.find(to)
      return str if s.encoding == to_enc

      if from
        from_enc = ::Encoding.find(from)
        s.force_encoding(from) unless s.encoding == from_enc
      end

      begin
        s.encode(to)
      rescue ::Encoding::InvalidByteSequenceError, ::Encoding::UndefinedConversionError => e
        # iPhone MailがISO-2022-JPに半角カナや①などのCP50220文字を含めてくる問題対策
        if s.encoding == ::Encoding::ISO2022_JP
          s.force_encoding(::Encoding::CP50220)
          retry
        else
          raise e
        end
      end
    end

    def set_encoding(str, encoding)
      encoding = SJIS if encoding =~ /shift_jis/i
      str.force_encoding(encoding)

      str
    end

    def extract_charset(str)
      case str
      when /iso-2022-jp/i
        "ISO-2022-JP"
      when /shift_jis/i
        "Shift_JIS"
      when /utf-8/i
        "UTF-8"
      else
        ""
      end
    end

    def detect_encoding(str)
      case str.encoding
      when ::Encoding::ISO2022_JP
        JIS
      when ::Encoding::Shift_JIS, ::Encoding::Windows_31J, ::Encoding::CP932
        SJIS
      when ::Encoding::UTF_8
        UTF8
      when ::Encoding::ASCII_8BIT
        BINARY
      else
        BINARY
      end
    end

    def ascii_8bit?(str)
      detect_encoding(str) == BINARY
    end
    def utf8?(str)
      detect_encoding(str) == UTF8
    end
    def shift_jis?(str)
      detect_encoding(str) == SJIS
    end
    def jis?(str)
      detect_encoding(str) == JIS
    end

    def fold_text(str, size = 15)
      folded_texts = []

      while texts = split_text(str, size) and texts.first.size != 0
        folded_texts << texts.first
        str = texts.last
      end

      folded_texts
    end

    def split_text(str, size = 15)
      return nil if str.nil? or str == ''

      [str[0..(size-1)], str[size..-1]]
    end

    def invert_table(hash)
      result = {}
      hash.keys.each do |key|
        if result[hash[key]]
          if !key.kind_of?(Array) and !result[hash[key]].kind_of?(Array) and result[hash[key]] > key
            result[hash[key]] = key
          end
        else
          result[hash[key]] = key
        end
      end
      result
    end

    def decode(str, encoding, charset)
      _str = case encoding
             when /quoted-printable/i
               str.unpack('M').first.strip
             when /base64/i
               str.unpack('m').first.strip
             else
               str
             end

      _extract_charset = Jpmobile::Util.extract_charset(_str)
      charset = _extract_charset unless _extract_charset.blank? or _extract_charset == charset
      Jpmobile::Util.set_encoding(_str, charset)
    end
  end
end
