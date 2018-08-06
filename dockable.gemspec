
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dockable/version"

Gem::Specification.new do |spec|
  spec.name          = "dockable"
  spec.version       = Dockable::VERSION
  spec.authors       = ["iain"]
  spec.email         = ["iain@iain.nl"]
  spec.summary       = %q{Some helpers for launching Ruby apps inside Docker}
  spec.description   = %q{Some helpers for launching Ruby apps inside Docker}
  spec.homepage      = "https://teachable.com"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "aws-sdk-ssm"
end
