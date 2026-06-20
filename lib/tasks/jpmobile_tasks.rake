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
    skip = !args.skip.nil?

    unless skip
      # generate rails app
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      `bundle exec rails new #{rails_root} --skip-bundle --skip-bootsnap --skip-webpack-install --skip-git --skip-spring`
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
      File.write(config_path, <<-SESSION_CONFIG)
        Rails.application.config.session_store :active_record_store, :key => '_session_id'
        Rails.application.config.session_options = { :cookie_only => false }
      SESSION_CONFIG
    end

    unless skip
      # add gems for jpmobile spec
      gemfile_path = File.join(rails_root, 'Gemfile')
      File.open(gemfile_path, 'a+') do |file|
        file.write <<-GEMFILE
        instance_eval File.read(File.expand_path(__FILE__) + '.jpmobile')
        GEMFILE
      end
    end

    # run tests in rails
    gem_root = Dir.pwd
    Dir.chdir(rails_root) do
      Bundler.with_unbundled_env do
        original_env = ENV.to_hash

        ENV.update('RBENV_VERSION' => nil)
        ENV.update('RBENV_DIR' => nil)
        # Let the app's SimpleCov write results back into the gem's coverage dir.
        ENV.update('JPMOBILE_GEM_ROOT' => gem_root) if ENV['COVERAGE']

        system 'bundle install'
        system 'bin/rails db:migrate RAILS_ENV=test' unless skip
        system 'bin/rails spec', exception: true

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

desc 'Run the full test suite with coverage and emit a merged report'
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['test'].invoke
  Rake::Task['coverage:report'].invoke
end

namespace :coverage do
  # The Rails run (test:rails) exercises a *copy* of jpmobile under
  # test/rails/rails_root/vendor/jpmobile, so its result paths differ from the
  # in-process unit/rack runs. Rewrite those paths back onto the real lib/ tree
  # so SimpleCov merges them as the same files, then collate everything.
  desc 'Merge SimpleCov results from all test runs into a single report'
  task :report do
    require 'simplecov'
    require 'simplecov-lcov'
    require 'simplecov_json_formatter'
    require 'json'

    gem_root = Dir.pwd
    specs_result = File.join(gem_root, 'coverage', '.resultset.json')
    rails_result = File.join(gem_root, 'coverage', 'rails', '.resultset.json')

    result_files = []
    result_files << specs_result if File.exist?(specs_result)

    if File.exist?(rails_result)
      data = JSON.parse(File.read(rails_result))
      data.each_value do |command|
        next unless command.is_a?(Hash) && command['coverage'].is_a?(Hash)

        command['coverage'] = command['coverage'].transform_keys do |path|
          path.sub(%r{.*/rails_root/vendor/jpmobile/}, "#{gem_root}/")
        end
      end
      fixed = File.join(gem_root, 'coverage', 'rails', '.resultset-remapped.json')
      File.write(fixed, JSON.generate(data))
      result_files << fixed
    end

    abort 'No SimpleCov results found. Run `rake coverage` first.' if result_files.empty?

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    SimpleCov.collate(result_files) do
      track_files 'lib/**/*.rb'
      add_filter '/spec/'
      add_filter '/test/'
      add_filter '/vendor/'
      enable_coverage :branch
      formatter SimpleCov::Formatter::MultiFormatter.new(
        [
          SimpleCov::Formatter::JSONFormatter,
          SimpleCov::Formatter::LcovFormatter,
        ],
      )
    end
  end
end
