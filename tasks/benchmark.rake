require 'jmespath'

task 'benchmark' do
  module JMESPath
    Dir.glob('benchmark/*.json').each do |path|
      load_json(path).first.tap do |scenario|
        scenario['cases'].each do |test_case|
          time = Benchmark.time(test_case['expression'], scenario['given'])
          label = "#{scenario['description']} - #{test_case['name']}"
          printf("%fms, %s\n" % [time * 1000, label])
        end
      end
    end
  end
end
