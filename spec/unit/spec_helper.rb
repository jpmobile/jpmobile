require 'rubygems'
require 'rspec'
require 'rspec/its'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'jpmobile'
begin
  require File.dirname(__FILE__)+'/../../vendor/jpmobile-ipaddresses/lib/jpmobile-ipaddresses'
rescue LoadError
  puts "IP Address test requires jpmobile-ipaddresses module"
end
begin
  require File.dirname(__FILE__)+'/../../vendor/jpmobile-terminfo/lib/jpmobile-terminfo'
rescue LoadError
  puts "Terminal display information test requires jpmobile-terminfo module"
end

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.color = true
  config.filter_run_excluding :broken => true
  # config.full_backtrace = true
end
