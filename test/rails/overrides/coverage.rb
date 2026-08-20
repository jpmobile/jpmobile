if ENV['COVERAGE'] && ENV['JPMOBILE_GEM_ROOT']
  # Descendants would overwrite the Rails resultset with nearly empty coverage under the same command name.
  require 'shellwords'
  rubyopt = Shellwords.split(ENV.fetch('RUBYOPT', '')).reject {|option| option == '-r./coverage.rb' }
  ENV['RUBYOPT'] = Shellwords.join(rubyopt)
  ENV.delete('RUBYOPT') if ENV['RUBYOPT'].empty?

  require 'simplecov'

  SimpleCov.root(File.expand_path('vendor/jpmobile', __dir__))
  SimpleCov.coverage_dir(File.join(ENV['JPMOBILE_GEM_ROOT'], 'coverage', 'rails'))
  SimpleCov.start do
    command_name 'rails'
    track_files 'lib/**/*.rb'
    # Host-app files cannot be merged with the in-process jpmobile runs.
    add_filter {|src| !src.filename.include?('/vendor/jpmobile/lib/') }
    enable_coverage :branch
    use_merging true
    formatter SimpleCov::Formatter::SimpleFormatter
  end
end
