version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|

  spec.name          = 'jmespath'
  spec.version       = version
  spec.summary       = 'JMESPath - Ruby Edition'
  spec.description   = 'Implementes JMESPath for Ruby'
  spec.author        = 'Trevor Rowe'
  spec.email         = 'trevorrowe@gmail.com'
  spec.homepage      = 'http://github.com/trevorrowe/jmespath.rb'
  spec.license       = 'Apache 2.0'
  spec.require_paths = ['lib']
  spec.files = Dir['lib/**/*.rb']
  spec.add_dependency('multi_json', '~> 1.0')
end
