# desc "Explaining what the task does"
# task :jpmobile do
#   # Task goes here
# end

begin
  require 'rspec/core/rake_task'

  namespace :spec do
    desc 'run unit testing (core test)'
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = 'spec/unit/**/*_spec.rb'
    end

    desc 'run rack testing'
    RSpec::Core::RakeTask.new(:rack) do |t|
      t.pattern = 'spec/rack/**/*_spec.rb'
    end
  end
rescue LoadError
  warn 'RSpec is not installed. Some tasks were skipped. please install rspec'
end

namespace :test do
  desc 'Generate rails app and run jpmobile tests in the app'
  task :rails, [:skip] do |_, args|
    rails_root = 'test/rails/rails_root'

    puts 'Running tests in Rails'
    skip = args.skip == 'true'

    unless skip
      # generate rails app
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      `rails new #{rails_root} --skip-bundle`
    end

    # setup jpmobile
    plugin_path = File.join(rails_root, 'vendor', 'jpmobile')
    FileUtils.mkdir_p(plugin_path)
    FileList['*'].exclude('test').exclude('spec').exclude('vendor').each do |file|
      FileUtils.cp_r(file, plugin_path)
    end

    # setup jpmobile-ipaddresses
    begin
      plugin_path = File.join(rails_root, 'vendor', 'jpmobile-ipaddresses')
      FileUtils.mkdir_p(plugin_path)
      FileList['vendor/jpmobile-ipaddresses/*'].exclude('test').each do |file|
        FileUtils.cp_r(file, plugin_path)
      end
    rescue LoadError
      puts 'IP Address test requires jpmobile-ipaddresses module'
    end

    # setup jpmobile-terminfo
    begin
      plugin_path = File.join(rails_root, 'vendor', 'jpmobile-terminfo')
      FileUtils.mkdir_p(plugin_path)
      FileList['vendor/jpmobile-terminfo/*'].exclude('test').each do |file|
        FileUtils.cp_r(file, plugin_path)
      end
    rescue LoadError
      puts 'Terminal display information test requires jpmobile-terminfo module'
    end

    # setup activerecord-session_store
    begin
      plugin_path = File.join(rails_root, 'vendor', 'activerecord-session_store')
      FileUtils.mkdir_p(plugin_path)
      FileList['../activerecord-session_store/*'].exclude('test').each do |file|
        FileUtils.cp_r(file, plugin_path)
      end
    rescue LoadError
      puts 'Terminal display information test requires jpmobile-terminfo module'
    end

    # setup tests
    FileList['test/rails/overrides/*'].each do |file|
      FileUtils.cp_r(file, rails_root)
    end

    unless skip
      # for cookie_only option
      config_path = File.join(rails_root, 'config', 'initializers', 'session_store.rb')
      File.open(config_path, 'w') do |file|
        file.write <<-SESSION_CONFIG
        Rails.application.config.session_store :active_record_store, :key => '_session_id'
        Rails.application.config.session_options = { :cookie_only => false }
        SESSION_CONFIG
      end
    end

    unless skip
      # add gems for jpmobile spec
      config_path = File.join(rails_root, 'Gemfile')
      File.open(config_path, 'a+') do |file|
        file.write <<-GEMFILE
        instance_eval File.read(File.expand_path(__FILE__) + '.jpmobile')
        GEMFILE
      end
    end

    # run tests in rails
    Dir.chdir(rails_root) do
      Bundler.with_clean_env do
        original_env = ENV.to_hash

        ENV.update('RBENV_VERSION' => nil)
        ENV.update('RBENV_DIR' => nil)

        system 'bundle install'
        system 'bin/rails db:migrate RAILS_ENV=test' unless skip
        system 'bin/rails spec'

        ENV.replace(original_env)
      end
    end
  end
  desc 'Run sinatra on jpmobile tests'
  Rake::TestTask.new(:sinatra) do |t|
    t.libs << 'lib'
    t.libs << 'test/sinatra'
    t.pattern = 'test/sinatra/test/*_test.rb'
    t.verbose = true
  end
end
