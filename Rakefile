require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'fileutils'
include FileUtils

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "jpmobile"
    gem.summary = "A Rails plugin for Japanese mobile-phones"
    gem.description = "A Rails plugin for Japanese mobile-phones"
    gem.email = "dara@shidara.net"
    gem.homepage = "http://github.com/jpmobile/jpmobile"
    gem.authors = ["Yoji Shidara", "Shin-ichiro OGAWA"]

    gem.test_files.exclude 'test/rails/rails_root'

    gem.add_development_dependency('rspec', '>=1.3.0')
    gem.add_development_dependency('rspec-rails', '>=1.3.2')
    gem.add_development_dependency('rspec-fixture', '>=0.0.2')
    gem.add_development_dependency('jeweler', '>=1.4.0')
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
Jeweler::GemcutterTasks.new

desc 'Default: run unit tests.'
task :default => :test

desc 'Generate documentation for the jpmobile plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Jpmobile'
  rdoc.options << '--line-numbers' << '--inline-source' << '-c UTF-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Update misc tables"
task :update do
  Dir.glob("tools/update_*.rb").each do |path|
    ruby path
  end
end

task :test => ['test:legacy', 'spec:unit', 'spec:rack', 'test:rails']
load 'lib/tasks/jpmobile_tasks.rake'
