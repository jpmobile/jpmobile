module Jpmobile
  autoload :Emoticon, 'jpmobile/emoticon'
  module Mobile
    autoload :Docomo,    'jpmobile/mobile/docomo'
    autoload :Au,        'jpmobile/mobile/au'
    autoload :Softbank,  'jpmobile/mobile/softbank'
    autoload :Vodafone,  'jpmobile/mobile/softbank'
    autoload :Jphone,    'jpmobile/mobile/softbank'
    autoload :Emobile,   'jpmobile/mobile/emobile'
    autoload :Willcom,   'jpmobile/mobile/willcom'
    autoload :Ddipocket, 'jpmobile/mobile/willcom'
  end
end

%w(
  jpmobile/mobile/abstract_mobile.rb
  jpmobile/mobile/display.rb
).each do |lib|
  require File.join(File.dirname(__FILE__), lib)
end

if ENV["RAILS_ENV"]
  Dir[File.join(File.dirname(__FILE__), 'jpmobile/*.rb')].sort.each { |lib| 
    require lib 
  }
end
