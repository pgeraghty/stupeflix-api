# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stupeflix/version'

Gem::Specification.new do |gem|
  gem.name          = 'stupeflix'
  gem.version       = Stupeflix.version
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Paul Geraghty']
  gem.email         = ['muse@appsthatcould.be']
  gem.description   = %q{Stupeflix API wrapper using HTTParty}
  gem.summary       = %q{Stupeflix API wrapper using HTTParty}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'httparty', '>= 0'
end
