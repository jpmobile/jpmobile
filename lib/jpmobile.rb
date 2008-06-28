Dir[File.join(File.dirname(__FILE__), 'jpmobile/**/*.rb')].sort.each { |lib| 
  next if lib =~ %r{jpmobile/mobile/z_(.*?)} # lazy loading data.
  require lib 
}
