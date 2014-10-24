task 'release:require-version' do
  unless ENV['VERSION']
    warn("usage: VERSION=x.y.z rake release")
    exit
  end
end

task 'release:bump-version' do
  sh("echo '#{$VERSION}' > VERSION")
  path = 'lib/jmespath/version.rb'
  file = File.read(path)
  file = file.gsub(/VERSION = '.+?'/, "VERSION = '#{$VERSION}'")
  File.open(path, 'w') { |f| f.write(file) }
  sh("git add #{path}")
  sh("git add VERSION")
end

task 'release:stage' => [
  'release:require-version',
  'github:require-access-token',
  'git:require-clean-workspace',
  'test:unit',
  'changelog:version',
  'release:bump-version',
  'git:tag',
  'gem:build',
  'docs:zip',
]

task 'release:publish' => [
  'git:push',
  'gem:push',
  'github:release',
]

task 'release:cleanup' => [
  'changelog:next_release',
]

desc "Public release"
task :release => ['release:stage', 'release:publish', 'release:cleanup']
