require 'rubygems'
require 'rspec'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'jpmobile'
begin
  require File.dirname(__FILE__)+'/../../vendor/jpmobile-ipaddresses/lib/jpmobile-ipaddresses'
rescue LoadError
  puts "[NOTICE] IP Address test requires jpmobile-ipaddresses module"
end
