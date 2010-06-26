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

    def ascii_8bit(str)
      if str.respond_to?(:force_encoding)
        str.force_encoding("ASCII-8BIT")
      end
      str
    end

    def utf8_to_sjis(utf8_str)
      if utf8_str.respond_to?(:encode)
        utf8_str.encode("Shift_JIS")
      else
        NKF.nkf("-m0 -x -Ws", utf8_str)
      end
    end

    def sjis_to_utf8(sjis_str)
      if sjis_str.respond_to?(:encode)
        sjis_str.encode("UTF-8")
      else
        NKF.nkf("-m0 -x -Sw", sjis_str)
      end
    end

    def hash_to_utf8(hash)
      new_hash = {}
      hash.each do |keu, value|
        new_hash[utf8(key)] = utf8(value)
      end
    end
  end
end
