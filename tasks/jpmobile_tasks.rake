# desc "Explaining what the task does"
# task :jpmobile do
#   # Task goes here
# end

begin
  require 'spec'
  namespace :spec do
    desc 'run unit testing ( core test )'
    Spec::Rake::SpecTask.new(:unit) do |t|
      t.spec_opts = 'spec/spec.opts'
      t.spec_files = FileList['spec/unit/**/*_spec.rb']
    end
  end
rescue LoadError
  warn "task: spec:unit was skipped. please install rspec"
end
