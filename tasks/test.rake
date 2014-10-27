require 'rspec/core/rake_task'

$RSPEC_OPTS = ENV['VERBOSE'] ? ' --format doc --color' : ''

desc "Run unit tests"
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = "-I lib#{$RSPEC_OPTS}"
  t.pattern = 'spec/jmespath_spec.rb'
end

desc "Run compliance tests"
RSpec::Core::RakeTask.new('test:compliance') do |t|
  t.rspec_opts = "-I lib#{$RSPEC_OPTS}"
  t.pattern = 'compliance_spec.rb'
end

desc "Run performance tests"
RSpec::Core::RakeTask.new('test:perf') do |t|
  t.rspec_opts = "-I lib#{$RSPEC_OPTS}"
  t.pattern = 'perf_spec.rb'
end

task 'test' => ['test:unit', 'test:compliance']
