# -*- coding: utf-8 -*-
require 'rack/utils'
require 'singleton'

module Jpmobile
  module Rack
    module_function
    def mount_middlewares
      # 漢字コード・絵文字フィルター
      ::Rails.application.middleware.insert_after Jpmobile::Rack::MobileCarrier, Jpmobile::Rack::ParamsFilter
      ::Rails.application.middleware.insert_after Jpmobile::Rack::ParamsFilter, Jpmobile::Rack::Filter
    end
  end
end
