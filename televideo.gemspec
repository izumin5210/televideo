# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'televideo/version'

Gem::Specification.new do |spec|
  spec.name          = "televideo"
  spec.version       = Televideo::VERSION
  spec.authors       = ["izumin5210"]
  spec.email         = ["masayuki@izumin.info"]

  spec.summary       = %q{Proxy server to record HTTP request/response with VCR}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/izumin5210/televideo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "vcr", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "webmock", "~> 2.3"
end
