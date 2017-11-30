$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__)) ||
                                                  $LOAD_PATH.include?(__dir__)
require 'jpmobile/version'
require 'singleton'
require 'rack/utils'

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

    DEFAULT_CARRIERS = %w[Docomo Au Softbank Vodafone Emobile Willcom Ddipocket Ipad AndroidTablet Iphone Android WindowsPhone BlackBerry].freeze

    def self.carriers
      @carriers ||= DEFAULT_CARRIERS.dup
    end

    def self.carriers=(ary)
      @carriers = ary
    end

    require 'jpmobile/mobile/abstract_mobile'
  end

  autoload :Configuration, 'jpmobile/configuration'

  autoload :MobileCarrier, 'jpmobile/rack/mobile_carrier'
  autoload :ParamsFilter,  'jpmobile/rack/params_filter'
  autoload :Filter,        'jpmobile/rack/filter'

  autoload :Mailer,   'jpmobile/mailer'
  autoload :Resolver, 'jpmobile/resolver'

  autoload :FallbackViewSelector, 'jpmobile/fallback_view_selector'

  autoload :ParamsOverCookie,    'jpmobile/trans_sid'
  autoload :TransSidRedirecting, 'jpmobile/trans_sid'
  autoload :TransSid,            'jpmobile/trans_sid'

  module_function

  def config
    ::Jpmobile::Configuration.instance
  end

  def mount_middlewares
    # 漢字コード・絵文字フィルター
    ::Rails.application.middleware.insert_after ::Jpmobile::MobileCarrier, ::Jpmobile::ParamsFilter
    ::Rails.application.middleware.insert_after ::Jpmobile::ParamsFilter,  ::Jpmobile::Filter
  end
end

if defined?(Rails)
  require 'jpmobile/rails'
end
