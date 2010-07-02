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
