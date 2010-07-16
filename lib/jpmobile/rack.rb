# -*- coding: utf-8 -*-
require 'jpmobile/datum_conv'

module Jpmobile
  module Rack
    autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier.rb'
    autoload :ParamsFilter,  'jpmobile/rack/params_filter.rb'
    autoload :Filter,        'jpmobile/rack/filter.rb'
    autoload :Config,        'jpmobile/rack/config.rb'

    module_function
    def mount_middlewares
      # 漢字コード・絵文字フィルター
      ::Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::ParamsFilter)
      ::Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::Filter)
    end
  end

  class Configuration
    def mobile_filter
      ::Jpmobile::Rack.mount_middlewares
    end
  end
end

if Object.const_defined?(:Rails)
  # MobileCarrierのみデフォルトで有効
  ::Rails::Application.config.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::MobileCarrier)

  module Rails
    class Application
      class Configuration
        def jpmobile
          @jpmobile ||= ::Jpmobile::Configuration.new
        end
      end
    end
  end
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
