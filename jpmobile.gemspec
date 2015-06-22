# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jpmobile/version'

Gem::Specification.new do |gem|
  gem.name          = "jpmobile"
  gem.version       = Jpmobile::VERSION
  gem.authors       = ["Shin-ichiro OGAWA", "Yoji Shidara"]
  gem.email         = ["rust.stnard@gmail.com"]
  gem.description   = %q{A Rails plugin for mobile devices in Japan}
  gem.summary       = %q{A Rails plugin for mobile devices in Japan}
  gem.homepage      = 'http://jpmobile-rails.org'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rails'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'capybara-webkit'
  gem.add_development_dependency 'geokit'
  gem.add_development_dependency 'sqlite3-ruby'
  gem.add_development_dependency 'hpricot'
  gem.add_development_dependency 'git'
  gem.add_development_dependency 'pry'
end
