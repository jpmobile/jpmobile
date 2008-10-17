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
  end
end
