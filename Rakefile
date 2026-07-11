require 'bundler/gem_tasks'
require 'rake/testtask'
require 'fileutils'
require 'pathname'

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

task :test => ['spec:unit', 'spec:rack', 'test:sinatra', 'test:rails']
load 'lib/tasks/jpmobile_tasks.rake'
