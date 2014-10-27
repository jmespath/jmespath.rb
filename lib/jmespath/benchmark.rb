require 'absolute_time'

module JMESPath
  module Benchmark
    class << self
      def time(expression, data)

        best_time = 9999

        1_000.times do
          started_at = AbsoluteTime.now
          JMESPath.search(expression, data)
          time_taken = AbsoluteTime.now - started_at
          best_time = time_taken if time_taken < best_time
        end

        best_time

      end
    end
  end
end
