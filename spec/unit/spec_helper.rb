require 'rubygems'
require 'rspec'
require 'rspec/its'
if ENV['COVERAGE']
  require_relative '../support/coverage'
  JpmobileCoverage.start('unit')
end
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'jpmobile'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.color = true
  config.filter_run_excluding broken: true
  # config.full_backtrace = true
end
