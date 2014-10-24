$VERSION = ENV['VERSION'] ||
  File.read(File.expand_path('../VERSION', __FILE__)).strip
$GITHUB_ACCESS_TOKEN = ENV['JMESPATH_GITHUB_ACCESS_TOKEN']

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

task 'default' => 'test'
