$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__)) ||
                                                  $LOAD_PATH.include?(__dir__)
require 'jpmobile/version'
require 'singleton'
require 'rack/utils'

module Jpmobile
  autoload :RequestWithMobile,        'jpmobile/request_with_mobile'
  autoload :RequestWithMobileTesting, 'jpmobile/request_with_mobile'
  autoload :Version,                  'jpmobile/version'

  # autoload mobile classes
  module Mobile
    autoload :SmartPhone,     'jpmobile/mobile/smart_phone'
    autoload :Iphone,         'jpmobile/mobile/iphone'
    autoload :Android,        'jpmobile/mobile/android'
    autoload :WindowsPhone,   'jpmobile/mobile/windows_phone'
    autoload :BlackBerry,     'jpmobile/mobile/black_berry'

    autoload :Tablet,         'jpmobile/mobile/tablet'
    autoload :AndroidTablet,  'jpmobile/mobile/android_tablet'
    autoload :Ipad,           'jpmobile/mobile/ipad'

    DEFAULT_CARRIERS = %w[Ipad AndroidTablet Iphone Android WindowsPhone BlackBerry].freeze

    def self.carriers
      @carriers ||= DEFAULT_CARRIERS.dup
    end

    def self.carriers=(ary)
      @all_variants = nil

      @carriers = ary
    end

    def self.all_variants
      return @all_variants if @all_variants

      @all_variants = carriers.map {|carrier|
        Jpmobile::Mobile.const_get(carrier).new({}, {}).variants
      }.flatten!.uniq
    end

    require 'jpmobile/mobile/abstract_mobile'
  end

  autoload :Configuration, 'jpmobile/configuration'

  autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier'
  autoload :Resolver, 'jpmobile/resolver'

  autoload :PathSet,         'jpmobile/path_set'
  autoload :TemplateDetails, 'jpmobile/template_details'

  autoload :ViewSelector,         'jpmobile/view_selector'
  autoload :FallbackViewSelector, 'jpmobile/fallback_view_selector'

  module_function

  def config
    ::Jpmobile::Configuration.instance
  end
end

if defined?(Rails)
  require 'jpmobile/rails'
end
