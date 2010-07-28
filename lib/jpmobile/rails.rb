# -*- coding: utf-8 -*-
require 'jpmobile/docomo_guid'
require 'jpmobile/filter'
require 'jpmobile/helper'
require 'jpmobile/hook_action_controller'
require 'jpmobile/hook_action_view'
require 'jpmobile/trans_sid'

# MobileCarrierのみデフォルトで有効
::Rails.application.middleware.insert_before('ActionDispatch::ParamsParser', Jpmobile::Rack::MobileCarrier)

module Rails
  class Application
    class Configuration
      def jpmobile
        @jpmobile ||= ::Jpmobile::Configuration.new
      end
    end
  end
end
