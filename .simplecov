SimpleCov.start do
  project_name 'jmespath.rb'
  add_filter '/spec/'
  merge_timeout 60 * 15 # 15 minutes
end
