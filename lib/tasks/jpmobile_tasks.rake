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
  desc "Generate rails app and run jpmobile tests in the app"
  task :rails, [:skip] do |t, args|
    rails_root     = "test/rails/rails_root"
    relative_root  = "../../../"

    puts "Running tests in Rails"
    skip = args.skip == "true"

    unless skip
      # generate rails app
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      `bundle exec rails new #{rails_root}`
    end

    # setup jpmobile
    plugin_path = File.join(rails_root, 'vendor', 'plugins', 'jpmobile')
    FileUtils.mkdir_p(plugin_path)
    FileList["*"].exclude("test").exclude("spec").each do |file|
      FileUtils.cp_r(file, plugin_path)
    end

    # setup jpmobile-ipaddresses
    begin
      plugin_path = File.join(rails_root, 'vendor', 'plugins', 'jpmobile-ipaddresses')
      FileUtils.mkdir_p(plugin_path)
      FileList["vendor/jpmobile-ipaddresses/*"].exclude("test").each do |file|
        FileUtils.cp_r(file, plugin_path)
      end
    rescue LoadError
      puts "IP Address test requires jpmobile-ipaddresses module"
    end

    # setup jpmobile-terminfo
    begin
      plugin_path = File.join(rails_root, 'vendor', 'plugins', 'jpmobile-terminfo')
      FileUtils.mkdir_p(plugin_path)
      FileList["vendor/jpmobile-terminfo/*"].exclude("test").each do |file|
        FileUtils.cp_r(file, plugin_path)
      end
    rescue LoadError
      puts "Terminal display information test requires jpmobile-terminfo module"
    end

    # setup tests
    FileList["test/rails/overrides/*"].each do |file|
      FileUtils.cp_r(file, rails_root)
    end

    unless skip
      # for cookie_only option
      config_path = File.join(rails_root, 'config', 'initializers', 'session_store.rb')
      File.open(config_path, 'w') do |file|
        file.write <<-END
Rails.application.config.session_store :active_record_store, :key => '_session_id'
Rails.application.config.session_options = {:cookie_only => false}
END
      end
    end

    # run tests in rails
    cd rails_root
    # ruby "-S bundle install"
    ruby "-S rake db:migrate test" unless skip
    ruby "-S rake spec"
    # ruby "-S rspec -b --color spec/requests/filter_spec.rb -e 'jpmobile integration spec HankakuInputFilterController SoftBank 910T からのアクセス it should behave like hankaku_filter :input => true のとき はtextareaの中では半角に変換されないこと'"
  end
  desc "Run sinatra on jpmobile tests"
  Rake::TestTask.new(:sinatra) do |t|
    t.libs << 'lib'
    t.libs << 'test/sinatra'
    t.pattern = 'test/sinatra/test/*_test.rb'
    t.verbose = true
  end
end
