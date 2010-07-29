# -*- coding: utf-8 -*-
# desc "Explaining what the task does"
# task :jpmobile do
#   # Task goes here
# end

begin
  require 'rspec/core/rake_task'

  namespace :spec do
    desc 'run unit testing (core test)'
    RSpec::Core::RakeTask.new(:unit) do |t|
      spec_dir = File.join(File.dirname(__FILE__), '../../', 'spec')
      # t.spec_opts = File.read(File.join(spec_dir, 'spec.opts')).split
      # t.spec_files = FileList[File.join(spec_dir, 'unit', '**', '*_spec.rb')]
      t.pattern = "#{spec_dir}/unit/*_spec.rb"
    end

    desc 'run rack testing'
    RSpec::Core::RakeTask.new(:rack) do |t|
      spec_dir = File.join(File.dirname(__FILE__), '../../', 'spec')
      # t.spec_opts = File.read(File.join(spec_dir, 'spec.opts')).split
      # t.spec_files = FileList[File.join(spec_dir, 'rack', '**', '*_spec.rb')]
      t.pattern = "#{spec_dir}/rack/**/*_spec.rb"
    end
  end
rescue LoadError
  warn "RSpec is not installed. Some tasks were skipped. please install rspec"
end

namespace :test do
  desc "run jpmobile legacy tests"
  Rake::TestTask.new(:legacy) do |t|
    t.libs << 'lib'
    t.pattern = 'test/legacy/**/*_test.rb'
    t.verbose = true
  end
  desc "Generate rails app and run jpmobile tests in the app"
  task :rails, [:versions] do |t, args|
    rails_root     = "test/rails/rails_root"
    relative_root  = "../../../"
    rails_versions = args.versions.split("/") rescue ["3.0.0.rc"]

    puts "Running tests in Rails #{rails_versions.join(', ')}"

    rails_versions.each do |rails_version|
      puts "  for #{rails_version}"
      # generate rails app
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      system "rails new #{rails_root}"

      # setup jpmobile
      plugin_path = File.join(rails_root, 'vendor', 'plugins', 'jpmobile')
      FileUtils.mkdir_p(plugin_path)
      FileList["*"].exclude("test").each do |file|
        FileUtils.cp_r(file, plugin_path)
      end

      # setup tests
      FileList["test/rails/overrides/*"].each do |file|
        FileUtils.cp_r(file, rails_root)
      end

      # for cookie_only option
      config_path = File.join(rails_root, 'config', 'initializers', 'session_store.rb')
      File.open(config_path, 'w') do |file|
        file.write <<-END
Rails.application.config.session_store :active_record_store, :key => '_session_id'
Rails.application.config.session_options = {:cookie_only => false}
END
      end

      # run tests in rails
      cd rails_root
      # ruby "-S bundle install"
      ruby "-S rake db:migrate test"
      ruby "-S rake spec"
      # ruby "-S rspec -b --color spec/requests/trans_sid_spec.rb"

      cd relative_root
    end
  end
  desc "Run sinatra on jpmobile tests"
  Rake::TestTask.new(:sinatra) do |t|
    t.libs << 'lib'
    t.libs << 'test/sinatra'
    t.pattern = 'test/sinatra/test/*_test.rb'
    t.verbose = true
  end
end
