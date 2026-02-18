require 'bundler/gem_tasks'
require 'rake/testtask'
require 'fileutils'
require 'pathname'
require 'git'

desc 'Default: run unit tests.'
task :default => :test

desc 'Update misc tables'
task :update do
  Dir.glob('tools/update_*.rb').each do |path|
    ruby path
  end
end

namespace :rbs do
  desc 'Validate RBS type definitions'
  task :validate do
    sh 'bundle exec rbs validate'
  end

  desc 'Run Steep type checker'
  task :check do
    sh 'bundle exec steep check'
  end

  desc 'Run all type checks (RBS validation + Steep)'
  task :all => [:validate, :check]
end

namespace :test do
  desc 'Preparation of external modules'
  task :prepare do
    external_repos = [
      'jpmobile-ipaddresses',
      'jpmobile-terminfo',
    ]
    github_prefix = 'https://github.com/jpmobile'
    vendor_path = Pathname.new(Dir.pwd).join('vendor')
    FileUtils.mkdir_p(vendor_path)

    FileUtils.cd(vendor_path) do
      external_repos.each do |repos|
        unless File.directory?("#{repos}/.git")
          Git.clone("#{github_prefix}/#{repos}.git", repos, { :path => vendor_path })
        end
      end
    end
  end
end

task :test => ['test:prepare', 'spec:unit', 'spec:rack', 'test:rails']
load 'lib/tasks/jpmobile_tasks.rake'
