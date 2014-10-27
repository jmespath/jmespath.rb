require 'jmespath'

task 'benchmark' do

  require 'absolute_time'

  if !ENV['CACHE']
    class JMESPath::Runtime
      def parse(expression)
        @parser.parse(expression)
      end
    end
  end

  Dir.glob('benchmark/*.json').each do |path|
    JMESPath.load_json(path).first.tap do |scenario|
      scenario['cases'].each do |test_case|

        expression = test_case['expression']
        data = scenario['given']

        time = 1_000.times.inject(9999) do |best, _|
          started = AbsoluteTime.now
          JMESPath.search(expression, data)
          stopped = AbsoluteTime.now
          [stopped - started, best].min
        end

        label = "#{scenario['description']} - #{test_case['name']}"
        printf("%fms, %s\n" % [time * 1000, label])

      end
    end
  end
end
