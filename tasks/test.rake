require 'rspec/core/rake_task'

desc "Run unit tests"
RSpec::Core::RakeTask.new('test:unit') do |t|
  t.rspec_opts = '-I lib'
  t.pattern = 'spec'
end

task 'test' => 'test:unit'
