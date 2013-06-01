# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) ||
                                          $:.include?(File.expand_path(File.dirname(__FILE__)))
require "jpmobile/version"

module Jpmobile
  autoload :Email,                    'jpmobile/email'
  autoload :Emoticon,                 'jpmobile/emoticon'
  autoload :Position,                 'jpmobile/position'
  autoload :RequestWithMobile,        'jpmobile/request_with_mobile'
  autoload :RequestWithMobileTesting, 'jpmobile/request_with_mobile'
  autoload :Util,                     'jpmobile/util'
  autoload :Encoding,                 'jpmobile/encoding'
  autoload :Version,                  'jpmobile/version'
  autoload :DatumConv,                'jpmobile/datum_conv'

  # autoload mobile classes
  module Mobile
    autoload :Docomo,         'jpmobile/mobile/docomo'
    autoload :Au,             'jpmobile/mobile/au'
    autoload :Softbank,       'jpmobile/mobile/softbank'
    autoload :Vodafone,       'jpmobile/mobile/vodafone'
    autoload :Emobile,        'jpmobile/mobile/emobile'
    autoload :Willcom,        'jpmobile/mobile/willcom'
    autoload :Ddipocket,      'jpmobile/mobile/ddipocket'

    autoload :SmartPhone,     'jpmobile/mobile/smart_phone'
    autoload :Iphone,         'jpmobile/mobile/iphone'
    autoload :Android,        'jpmobile/mobile/android'
    autoload :WindowsPhone,   'jpmobile/mobile/windows_phone'
    autoload :BlackBerry,     'jpmobile/mobile/black_berry'

    autoload :Tablet,         'jpmobile/mobile/tablet'
    autoload :AndroidTablet,  'jpmobile/mobile/android_tablet'
    autoload :Ipad,           'jpmobile/mobile/ipad'

    autoload :Display,        'jpmobile/mobile/display'

    autoload :UnicodeEmoticon, 'jpmobile/mobile/unicode_emoticon'
    autoload :GoogleEmoticon, 'jpmobile/mobile/google_emoticon'

    DEFAULT_CARRIERS = %w(Docomo Au Softbank Vodafone Emobile Willcom Ddipocket Ipad AndroidTablet Iphone Android WindowsPhone BlackBerry)

    def self.carriers
      @carriers ||= DEFAULT_CARRIERS.dup
    end

    def self.carriers=(ary)
      @carriers = ary
    end

    require 'jpmobile/mobile/abstract_mobile'
  end

  # autoload Rack middlewares
  autoload :Rack, 'jpmobile/rack'
  module Rack
    autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier'
    autoload :ParamsFilter,  'jpmobile/rack/params_filter'
    autoload :Filter,        'jpmobile/rack/filter'
  end
  autoload :Configuration, 'jpmobile/configuration'

  autoload :Mailer,   'jpmobile/mailer'
  autoload :Resolver, 'jpmobile/resolver'

  module_function
  def config
    ::Jpmobile::Configuration.instance
  end
end

if defined?(Rails)
  require 'jpmobile/rails'
end
