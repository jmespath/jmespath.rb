require 'rspec/core/rake_task'

desc "Run unit tests"
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = '-I lib'
  t.pattern = 'spec'
  t.exclude_pattern = 'spec/compliance_spec.rb'
end

desc "Run compliance tests"
RSpec::Core::RakeTask.new('test:compliance') do |t|
  t.rspec_opts = '-I lib spec/compliance_spec.rb'
end

task 'test' => ['test:unit', 'test:compliance']
