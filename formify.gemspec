lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formify/version'

Gem::Specification.new do |spec|
  spec.name          = 'formify'
  spec.version       = Formify::VERSION
  spec.authors       = ['Ryan Jackson']
  spec.email         = ['ryanwjackson@gmail.com']

  spec.summary       = 'Formify gives structure to using form objects in a Rails project.'
  spec.description   = 'Formify acts as an abstract class, allowing you to easily create robust form objects and test them using rspec.'
  spec.homepage      = 'https://www.github.com/ryanwjackson/formify'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_runtime_dependency 'rails'
  spec.add_runtime_dependency 'resonad'
  spec.add_runtime_dependency 'with_advisory_lock'
end
