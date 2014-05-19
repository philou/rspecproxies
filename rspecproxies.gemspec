# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspecproxies/version'

Gem::Specification.new do |spec|
  spec.name          = "rspecproxies"
  spec.version       = RSpecProxies::VERSION
  spec.authors       = ["Philou"]
  spec.email         = ["philippe.bourgau@gmail.com"]
  spec.description   = %q{Proxy doubles for RSpec}
  spec.summary       = %q{Special RSpec extensions to simplify mocking by providing proxies}
  spec.homepage      = "https://github.com/philou/rspecproxies"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
