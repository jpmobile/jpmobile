require 'tempfile'
module Jpmobile
  module Util
    module_function

    def deep_apply(obj, &proc)
      case obj
      when Hash
        new_obj = {}
        obj.each_pair do |key, value|
          new_key = deep_apply(key, &proc)
          new_obj[new_key] = deep_apply(value, &proc)
        end
        new_obj
      when Array
        obj.collect!{|value| deep_apply(value, &proc)}
      when NilClass, TrueClass, FalseClass, Tempfile, StringIO
        return obj
      else
        obj = obj.to_param if obj.respond_to?(:to_param)
        proc.call(obj)
      end
    end
  end
end
