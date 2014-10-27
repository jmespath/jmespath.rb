$GEM_ROOT = File.dirname(__FILE__)

$: << File.join($GEM_ROOT, 'lib')

$VERSION = ENV['VERSION'] || File.read(File.join($GEM_ROOT, 'VERSION'))
$GITHUB_ACCESS_TOKEN = ENV['JMESPATH_GITHUB_ACCESS_TOKEN']

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

task 'default' => 'test'
