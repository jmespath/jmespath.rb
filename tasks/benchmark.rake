require 'jmespath'

desc 'Runs the benchmark suite'
task 'benchmark' do

  require 'absolute_time'

  runtime = JMESPath::Runtime.new(cache_expressions: !!ENV['CACHE'])

  # The benchmarks are taken from the boto/jmespath project from the
  # pref/ directory.
  Dir.glob('benchmark/*.json').each do |path|
    JMESPath.load_json(path).first.tap do |scenario|
      scenario['cases'].each do |test_case|

        expression = test_case['expression']
        data = scenario['given']

        time = 1_000.times.inject(9999) do |best, _|
          started = AbsoluteTime.now
          runtime.search(expression, data)
          stopped = AbsoluteTime.now
          [stopped - started, best].min
        end

        label = "#{scenario['description']} - #{test_case['name']}"
        printf("%fms, %s\n" % [time * 1000, label])

      end
    end
  end
end

desc 'Runs the benchmark suite, with expression caching'
task 'benchmark:cached' do
  sh({"CACHE" => "1"}, "bundle exec rake benchmark")
end
