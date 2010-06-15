require 'jpmobile/datum_conv'

module Jpmobile
  module Rack
    autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier.rb'
    autoload :ParamsFilter,  'jpmobile/rack/params_filter.rb'
    autoload :Filter,        'jpmobile/rack/filter.rb'
  end
end

if Object.const_defined?(:RAILS_ENV)
  begin
    ActionController::Dispatcher.middleware.insert_before 'ActionController::ParamsParser', Jpmobile::Rack::MobileCarrier
    ActionController::Dispatcher.middleware.insert_before 'ActionController::ParamsParser', Jpmobile::Rack::ParamsFilter
    ActionController::Dispatcher.middleware.insert_before 'ActionController::ParamsParser', Jpmobile::Rack::Filter
  rescue => ex
    require 'pp'
    pp ex
  end
end
