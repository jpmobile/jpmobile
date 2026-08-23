gem_root = ENV.fetch('JPMOBILE_GEM_ROOT', nil)
if ENV.fetch('COVERAGE', nil) && gem_root
  launcher = ENV.delete('JPMOBILE_COVERAGE_LAUNCHER')
  unless launcher
    ENV['RUBYOPT'] = ENV.fetch('RUBYOPT', '').split.reject {|option| option == '-r./coverage.rb' }.join(' ')
    ENV.delete('RUBYOPT') if ENV['RUBYOPT'].empty?
  end

  require 'simplecov'

  SimpleCov.root(File.expand_path('vendor/jpmobile', __dir__))
  SimpleCov.coverage_dir(File.join(gem_root, 'coverage', 'rails'))
  SimpleCov.start do
    command_name launcher ? 'rails-launcher' : 'rails'
    track_files 'lib/**/*.rb'
    # Host-app files cannot be merged with the in-process jpmobile runs.
    add_filter {|src| !src.filename.include?('/vendor/jpmobile/lib/') }
    enable_coverage :branch
    use_merging true
    formatter SimpleCov::Formatter::SimpleFormatter
  end
end
