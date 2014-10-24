task 'docs:clobber' do
  rm_rf ".yardoc"
  rm_rf "docs"
end

desc "Generates docs.zip"
task 'docs:zip' => :docs do
  sh("zip -9 -r -q docs.zip docs/")
end

desc "Generate the API documentation."
task :docs => ['docs:clobber'] do
  sh({"SOURCE" => "1"}, "bundle exec yard")
end
