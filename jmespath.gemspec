Gem::Specification.new do |spec|
  spec.name          = 'jmespath'
  spec.version       = File.read(File.expand_path('../VERSION', __FILE__)).strip
  spec.platform      = (defined? JRUBY_VERSION) ? 'java' : Gem::Platform::RUBY
  spec.summary       = 'JMESPath - Ruby Edition'
  spec.description   = 'Implements JMESPath for Ruby'
  spec.author        = ['Trevor Rowe', 'Theo Hultberg']
  spec.email         = 'trevorrowe@gmail.com'
  spec.homepage      = 'http://github.com/jmespath/jmespath.rb'
  spec.license       = 'Apache 2.0'
  spec.require_paths = ['lib']
  spec.files         = Dir['lib/**/*.rb', 'lib/**/*.jar', '.yardopts', 'README.md', 'LICENSE.txt', 'VERSION']
end
