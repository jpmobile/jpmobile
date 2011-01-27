require 'rubygems'
require 'rspec'
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

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.color_enabled = true
  c.filter_run_excluding :broken => true
  # c.full_backtrace = true
end
