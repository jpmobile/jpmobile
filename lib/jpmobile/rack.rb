# -*- coding: utf-8 -*-
require 'rack/utils'

module Jpmobile
  module Rack
    module_function
    def mount_middlewares
      # 漢字コード・絵文字フィルター
      ::Rails.application.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::ParamsFilter)
      ::Rails.application.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::Filter)
    end
  end

  class Configuration
    def mobile_filter
      ::Jpmobile::Rack.mount_middlewares
    end
  end
end

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
