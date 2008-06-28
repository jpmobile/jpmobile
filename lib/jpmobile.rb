module Jpmobile
  autoload :Emoticon, 'jpmobile/emoticon'
end

Dir[File.join(File.dirname(__FILE__), 'jpmobile/**/*.rb')].sort.each { |lib| 
  next if lib =~ %r{jpmobile/mobile/z_(.*?)} # lazy loading data.
  next if lib =~ %r{jpmobile/emoticon}
  require lib 
}
