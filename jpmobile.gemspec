lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jpmobile/version'

Gem::Specification.new do |gem|
  gem.name          = 'jpmobile'
  gem.version       = Jpmobile::VERSION
  gem.authors       = ['Shin-ichiro OGAWA', 'Yoji Shidara']
  gem.email         = ['rust.stnard@gmail.com']
  gem.description   = 'A Rails plugin for mobile devices in Japan'
  gem.summary       = 'Rails plugin for mobile devices in Japan'
  gem.homepage      = 'http://jpmobile-rails.org'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'mail', '~> 2.7.0'
  gem.add_development_dependency 'capybara-webkit'
  gem.add_development_dependency 'geokit'
  gem.add_development_dependency 'git'
  gem.add_development_dependency 'hpricot'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rails', '~> 5.2.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'sqlite3-ruby'
end
