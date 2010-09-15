require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'fileutils'
require 'pathname'
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

    gem.add_development_dependency('rspec', '2.0.0.beta.17')
    gem.add_development_dependency('rspec-rails', '2.0.0.beta.17')
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

task :test => ['test:prepare', 'test:legacy', 'spec:unit', 'spec:rack', 'test:rails']
load 'lib/tasks/jpmobile_tasks.rake'
