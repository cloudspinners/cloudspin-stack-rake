
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudspin/stack/rake/version'

Gem::Specification.new do |spec|
  spec.name          = 'cloudspin-stack-rake'
  spec.version       = Cloudspin::Stack::Rake::VERSION
  spec.authors       = ['kief ']
  spec.email         = ['cloudspin@kief.com']

  spec.summary       = 'Rake tasks to manage instances of an infrastructure stack using Terraform'
  spec.homepage      = 'https://github.com/cloudspinners'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.3'

  spec.add_dependency 'cloudspin-stack'
  spec.add_dependency 'inspec'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
