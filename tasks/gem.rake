desc 'Builds the gem'
task 'gem:build' do
  sh("gem build jmespath.gemspec")
end

task 'gem:push' do
  sh("gem push jmespath-#{$VERSION}.gem")
end
