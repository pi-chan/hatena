# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hatena/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.8', '< 0.10']
  spec.add_dependency 'nokogiri', ['>= 1.5.10']
  spec.add_dependency 'simple_oauth', '~> 0.2.0'
  spec.add_dependency 'xml-simple'
  spec.name          = "hatena"
  spec.version       = Hatena::VERSION
  spec.authors       = ["xoyip"]
  spec.email         = ["xoyip@piyox.info"]
  spec.description   = %q{Ruby interface for Hatena API}
  spec.summary       = %q{Ruby interface for Hatena API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
