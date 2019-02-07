Gem::Specification.new do |spec|
  spec.name          = 'jmespath'
  spec.version       = File.read(File.expand_path('../VERSION', __FILE__)).strip
  spec.summary       = 'JMESPath - Ruby Edition'
  spec.description   = 'Implements JMESPath for Ruby'
  spec.author        = 'Trevor Rowe'
  spec.email         = 'trevorrowe@gmail.com'
  spec.homepage      = 'http://github.com/trevorrowe/jmespath.rb'
  spec.license       = 'Apache-2.0'
  spec.require_paths = ['lib']
  spec.executables   = Dir['bin/**'].map &File.method(:basename)
  spec.files         = Dir['lib/**/*.rb'] + ['LICENSE.txt']
end
