require_relative 'lib/jpmobile/version'

Gem::Specification.new do |gem|
  gem.name          = 'jpmobile'
  gem.version       = Jpmobile::VERSION
  gem.authors       = ['Shin-ichiro OGAWA', 'Yoji Shidara']
  gem.email         = ['rust.stnard@gmail.com']
  gem.description   = 'A Rails plugin for mobile devices in Japan'
  gem.summary       = 'Rails plugin for mobile devices in Japan'
  gem.homepage      = 'https://jpmobile-rails.org'
  gem.license       = 'MIT'

  gem.metadata['source_code_uri'] = 'https://github.com/jpmobile/jpmobile'
  gem.metadata['documentation_uri'] = gem.metadata['source_code_uri']

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 3.3.0'

  gem.add_dependency 'mail', '~> 2.8.0'
  gem.add_dependency 'scanf'
  gem.metadata['rubygems_mfa_required'] = 'true'
end
