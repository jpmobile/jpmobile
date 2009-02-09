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
  desc 'run all specs (including rails integration tests)'
  Spec::Rake::SpecTask.new(:spec) do |t|
    spec_dir = File.join(File.dirname(__FILE__), '..', 'spec')
    t.spec_opts = File.read(File.join(spec_dir, 'spec.opts')).split
    t.spec_files = FileList[File.join(spec_dir, '*', '**', '*_spec.rb')]
  end
rescue LoadError
  warn "RSpec is not installed. Some tasks were skipped. please install rspec"
end
