# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kommand/version'

Gem::Specification.new do |spec|
  spec.name          = "kommand"
  spec.version       = Kommand::VERSION
  spec.authors       = ["Mark Rebec"]
  spec.email         = ["mark@markrebec.com"]
  spec.summary       = %q{Simple object-oriented interface for building CLI commands with subcommands.}
  spec.description   = %q{Simple object-oriented interface for building CLI commands with subcommands.}
  spec.homepage      = "https://github.com/markrebec/kommand"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "inkjet"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
