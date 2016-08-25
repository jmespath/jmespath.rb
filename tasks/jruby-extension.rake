if defined? JRUBY_VERSION
  namespace :extension do
    task :package do
      Dir.chdir('ext') do
        sh "mvn -Djruby.version=#{JRUBY_VERSION} package"
      end
    end

    task :install => :package do
      extension_jar = Dir['ext/target/jmespath-jruby-*-jar-with-dependencies.jar'].max
      extension_dir = 'lib/jmespath/ext'
      FileUtils.mkdir_p(extension_dir)
      FileUtils.cp(extension_jar, File.join(extension_dir, 'jmespath.jar'))
    end
  end

  task 'test:unit' => 'extension:install'
end
