# frozen_string_literal: true

# Shared SimpleCov bootstrap for the in-process spec runs (spec:unit / spec:rack).
# Must be required *before* 'jpmobile' so that load-time code is tracked.
# Enabled only when COVERAGE env var is set, so normal test runs are unaffected.
require 'simplecov'

module JpmobileCoverage
  module_function

  # @param command [String] distinct SimpleCov command name (e.g. 'unit', 'rack').
  #   Each parallel process needs a unique name so results merge instead of overwrite.
  def start(command)
    SimpleCov.start do
      command_name command
      cover 'lib/**/*.rb'
      skip '/spec/'
      skip '/test/'
      skip '/vendor/'
      enable_coverage :branch
      merging true
      # Defer human-readable reports to the `coverage:report` task.
      formatter SimpleCov::Formatter::SimpleFormatter
    end
  end
end
