# frozen_string_literal: true

require 'rspec/core/rake_task'

$RSPEC_OPTS = ENV['VERBOSE'] ? ' --format doc --color' : ''

desc 'Run unit tests'
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = "-I lib#{$RSPEC_OPTS}"
  t.exclude_pattern = 'spec/compliance_*.rb'
end

desc 'Run compliance tests'
RSpec::Core::RakeTask.new('test:compliance') do |t|
  t.rspec_opts = "-I lib#{$RSPEC_OPTS}"
  t.pattern = 'spec/compliance_*.rb'
end

task 'test' => ['test:unit', 'test:compliance']
task 'release:test' => :test
