require 'tempfile'
module Jpmobile
  module Util
    module_function
    def deep_apply(obj, &proc)
      case obj
      when Hash
        obj.each_pair do |key, value|
          obj[key] = deep_apply(value, &proc)
        end
      when Array
        obj.collect!{|value| deep_apply(value, &proc)}
      when NilClass, TrueClass, FalseClass, Tempfile, StringIO
        return obj
      else
        obj = obj.to_param if obj.respond_to?(:to_param)
        proc.call(obj)
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
      when NilClass, TrueClass, FalseClass, Tempfile, StringIO
        new_obj = obj
      else
        obj = obj.to_param if obj.respond_to?(:to_param)
        new_obj = proc.call(obj)
      end

      new_obj
    end

    def sjis(ascii_8bit)
      if ascii_8bit.respond_to?(:force_encoding)
        ascii_8bit.force_encoding("Shift_JIS")
      end
      ascii_8bit
    end

    def utf8(ascii_8bit)
      if ascii_8bit.respond_to?(:force_encoding)
        ascii_8bit.force_encoding("utf-8")
      end
      ascii_8bit
    end

    def jis(ascii_8bit)
      if ascii_8bit.respond_to?(:force_encoding)
        ascii_8bit.force_encoding("ISO-2022-JP")
      end
      ascii_8bit
    end

    def ascii_8bit(str)
      if str.respond_to?(:force_encoding)
        str.force_encoding("ASCII-8BIT")
      end
      str
    end

    def utf8_to_sjis(utf8_str)
      if utf8_str.respond_to?(:encode)
        utf8_str.encode("Shift_JIS", :crlf_newline => true)
      else
        NKF.nkf("-m0 -x -Ws", utf8_str).gsub(/\n/, "\r\n")
      end
    end

    def sjis_to_utf8(sjis_str)
      if sjis_str.respond_to?(:encode)
        sjis_str.encode("UTF-8", :universal_newline => true)
      else
        NKF.nkf("-m0 -x -Sw", sjis_str).gsub(/\r\n/, "\n")
      end
    end

    def utf8_to_jis(utf8_str)
      if utf8_str.respond_to?(:encode)
        utf8_str.encode("ISO-2022-JP", :crlf_newline => true)
      else
        NKF.nkf("-m0 -x -Wj", utf8_str).gsub(/\n/, "\r\n")
      end
    end

    def jis_to_utf8(jis_str)
      if jis_str.respond_to?(:encode)
        jis_str.encode("UTF-8", :universal_newline => true)
      else
        NKF.nkf("-m0 -x -Jw", jis_str).gsub(/\r\n/, "\n")
      end
    end

    def regexp_utf8_to_sjis(utf8_str)
      if Object.const_defined?(:Encoding)
        Regexp.compile(Regexp.escape(utf8_to_sjis(utf8_str)))
      else
        Regexp.compile(Regexp.escape(utf8_to_sjis(utf8_str),"s"),nil,'s')
      end
    end

    def hash_to_utf8(hash)
      new_hash = {}
      hash.each do |keu, value|
        new_hash[utf8(key)] = utf8(value)
      end
    end

    def sjis_regexp(sjis)
      if Object.const_defined?(:Encoding)
        Regexp.compile(Regexp.escape([sjis].pack('n').force_encoding("Shift_JIS")))
      else
        Regexp.compile(Regexp.escape([sjis].pack('n'),"s"),nil,'s')
      end
    end

    def jis_regexp(jis)
      if Object.const_defined?(:Encoding)
        Regexp.compile(Regexp.escape([jis].pack('n').force_encoding("stateless-ISO-2022-JP-KDDI"))) # for au only
      else
        Regexp.compile(Regexp.escape([jis].pack('n'),"j"),nil,'j')
      end
    end

    def encode(str, charset)
      if Object.const_defined?(:Encoding)
        str.encode(charset)
      else
        case charset
        when /iso-2022-jp/i
          NKF.nkf("-j", str)
        when /shift_jis/
          NKF.nkf("-s", str)
        when /utf-8/
          NKF.nkf("-w", str)
        else
          str
        end
      end
    end
  end
end
