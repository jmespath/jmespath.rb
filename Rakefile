$VERSION = File.read(File.expand_path('../VERSION', __FILE__)).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

task 'default' => 'test'
