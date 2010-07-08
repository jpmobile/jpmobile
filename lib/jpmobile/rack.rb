# -*- coding: utf-8 -*-
require 'jpmobile/datum_conv'

module Jpmobile
  module Rack
    autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier.rb'
    autoload :ParamsFilter,  'jpmobile/rack/params_filter.rb'
    autoload :Filter,        'jpmobile/rack/filter.rb'
    autoload :Config,        'jpmobile/rack/config.rb'
  end
end

if Object.const_defined?(:Rails)
  Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::MobileCarrier)
  Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::ParamsFilter)
  Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::Filter)
end

require 'rack/utils'
module Rack
  class Request
    def params
      self.GET.merge(self.POST)
    end
  end

  # UTF-8 で match させるようにする
  module Utils
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
    module_function :escape
    def unescape(s)
      s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/){
        [$1.delete('%')].pack('H*')
      }
    end
    module_function :unescape
  end
end
