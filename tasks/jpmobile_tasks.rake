# desc "Explaining what the task does"
# task :jpmobile do
#   # Task goes here
# end

begin
  require 'spec'
  require 'spec/rake/spectask'
  namespace :spec do
    desc 'run unit testing (core test)'
    Spec::Rake::SpecTask.new(:unit) do |t|
      spec_dir = File.join(File.dirname(__FILE__), '..', 'spec')
      t.spec_opts = File.read(File.join(spec_dir, 'spec.opts')).split
      t.spec_files = FileList[File.join(spec_dir, 'unit', '**', '*_spec.rb')]
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
    rails_versions = args.versions.split(",") rescue ["2.2.2"]
    rails_versions.each do |rails_version|
      puts "Running tests in Rails #{rails_version}"

      # generate rails app
      rails_root = "test/rails/rails_root"
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      system "rails _#{rails_version}_ -q --force #{rails_root}"

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

      # run tests in rails
      cd rails_root
      sh "rake db:migrate"
      sh "rake spec"
    end
  end
end

