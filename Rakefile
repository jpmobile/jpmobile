require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'jpmobile', 'version')

#
AUTHOR = "dara"
EMAIL = "dara@shidara.net"
DESCRIPTION = "A Rails plugin for Japanese mobile-phones"
RUBYFORGE_PROJECT = "jpmobile"
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
BIN_FILES = %w(  )

NAME = "jpmobile"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Jpmobile::VERSION::STRING + (REV ? ".#{REV}" : ""))
CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "jpmobile documentation",
    "--opname", "index.html",
    "--line-numbers",
    "--main", "README",
    "--inline-source"]

desc "Packages up jpmobile gem."
task :default => [:test, 'spec:unit']
task :package => [:clean]

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the jpmobile plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the jpmobile plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Jpmobile'
  rdoc.options << '--line-numbers' << '--inline-source' << '-c UTF-8'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = true
        s.extra_rdoc_files = ["README", "CHANGELOG"]
        s.rdoc_options += RDOC_OPTS + ['--exclude', '^(examples|extras)/']
        s.summary = DESCRIPTION
        s.description = DESCRIPTION
        s.author = AUTHOR
        s.email = EMAIL
        s.homepage = HOMEPATH
        s.executables = BIN_FILES
        s.rubyforge_project = RUBYFORGE_PROJECT
        s.bindir = "bin"
        s.require_path = "lib"

        s.add_dependency('actionpack', '>=2.1.0')

        #s.add_dependency('activesupport', '>=1.3.1')
        #s.required_ruby_version = '>= 1.8.2'

        s.files = %w(README CHANGELOG Rakefile) +
          Dir.glob("{bin,doc,test,lib,templates,generator,extras,website,script}/**/*") +
          Dir.glob("ext/**/*.{h,c,rb}") +
          Dir.glob("examples/**/*.rb") +
          Dir.glob("tools/*.rb")

        # s.extensions = FileList["ext/**/extconf.rb"].to_a
    end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = true
    p.gem_spec = spec
end

task :install do
  name = "#{NAME}-#{VERS}.gem"
  sh %{rake package}
  sh %{sudo gem install pkg/#{name}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

desc "Publish the API documentation"
task :pdoc => [:rdoc] do
  sh "rsync -azv --delete doc/ dara@rubyforge.org:/var/www/gforge-projects/jpmobile/rdoc/"
end

desc "Update misc tables"
task :update do
  Dir.glob("tools/update_*.rb").each do |path|
    ruby path
  end
end

desc "Release helper"
task :rel => [:gem] do
  puts "-"*40
  puts "rubyforge add_release #{NAME} #{NAME} #{VERS} pkg/#{NAME}-#{VERS}.gem"
  puts "git tag #{VERS}"
end

# setup RSpec tasks
RAILS_ROOT = '.'
load 'vendor/plugins/rspec-rails/tasks/rspec.rake'
load 'tasks/jpmobile_tasks.rake'
