# -*- coding: utf-8 -*-
# params を UTF-8 にする拡張
module Jpmobile
  module Encoding
    def self.included(base)
      base.class_eval do
        alias_method :parameters_without_jpmobile, :parameters

        def parameters
          return @parameters if @jpmobile_params_converted

          # load params
          @parameters = parameters_without_jpmobile
          # 変換
          @parameters = Jpmobile::Util.deep_convert(@parameters) do |value|
            value = Jpmobile::Util.utf8(value)
          end

          @jpmobile_params_converted = true
          if @parameters.respond_to?(:with_indifferent_access)
            @parameters = @parameters.with_indifferent_access
          end

          @parameters
        end
      end
    end
  end
end
