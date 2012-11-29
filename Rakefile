require "bundler/gem_tasks"
require 'rake/testtask'
require 'fileutils'
require 'pathname'
require 'git'
include FileUtils

desc 'Default: run unit tests.'
task :default => :test

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
