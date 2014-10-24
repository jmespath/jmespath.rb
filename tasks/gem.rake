desc 'Builds the gem'
task 'gem:build' do
  sh("gem build jmespath.gemspec")
end

task 'gem:push' do
  puts("gem push jmespath-#{$VERSION}.gem")
end
