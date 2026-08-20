if ENV['COVERAGE'] && ENV['JPMOBILE_GEM_ROOT']
  require 'simplecov'

  SimpleCov.root(File.expand_path('vendor/jpmobile', __dir__))
  SimpleCov.coverage_dir(File.join(ENV['JPMOBILE_GEM_ROOT'], 'coverage', 'rails'))
  SimpleCov.start do
    command_name 'rails'
    track_files 'lib/**/*.rb'
    add_filter {|src| !src.filename.include?('/vendor/jpmobile/lib/') }
    enable_coverage :branch
    use_merging true
    formatter SimpleCov::Formatter::SimpleFormatter
  end
end
