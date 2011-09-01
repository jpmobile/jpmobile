require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'fileutils'
require 'pathname'
require 'git'
include FileUtils

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "jpmobile"
    gem.summary = "A Rails plugin for Japanese mobile-phones"
    gem.description = "A Rails plugin for Japanese mobile-phones"
    gem.email = "dara@shidara.net"
    gem.homepage = "http://jpmobile-rails.org"
    gem.authors = ["Yoji Shidara", "Shin-ichiro OGAWA"]

    gem.files.exclude 'test'
    gem.files.exclude 'spec'
    gem.files.exclude 'vendor'

    gem.add_development_dependency('rails', '>=3.1.0')
    gem.add_development_dependency('jeweler', '>=1.5.1')
    gem.add_development_dependency('rspec', '>=2.6.0')
    gem.add_development_dependency('rspec-rails', '>=2.6.0')
    gem.add_development_dependency('webrat', '>=0.7.2')
    gem.add_development_dependency('geokit', '>=1.5.0')
    gem.add_development_dependency('sqlite3-ruby', '>=1.3.2')
    gem.add_development_dependency('hpricot', '>=0.8.3')
    gem.add_development_dependency('git', '>=1.2.5')
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

namespace :test do
  desc "Preparation of external modules"
  task :prepare do
    external_repos = [
      "jpmobile-ipaddresses",
      "jpmobile-terminfo"
    ]
    github_prefix = "git://github.com/jpmobile"
    vendor_path = Pathname.new(Dir.pwd).join("vendor")
    FileUtils.mkdir_p(vendor_path)

    FileUtils.cd(vendor_path) do
      external_repos.each do |repos|
        unless File.directory?("#{repos}/.git")
          Git.clone("#{github_prefix}/#{repos}.git", repos, {:path => vendor_path})
        end
      end
    end
  end
end

task :test => ['test:prepare', 'spec:unit', 'spec:rack', 'test:rails']
load 'lib/tasks/jpmobile_tasks.rake'
