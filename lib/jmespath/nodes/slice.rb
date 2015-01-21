module JMESPath
  # @api private
  module Nodes
    class Slice < Node
      attr_reader :args

      def initialize(args)
        @args = args
      end

      def visit(value)
        function_slice(value, *@args)
      end

      def to_h
        {
          :type => :slice,
          :args => @args,
        }
      end

      private

      def function_slice(values, *args)
        if String === values || Array === values
          _slice(values, *args)
        else
          nil
        end
      end

      def _slice(values, start, stop, step)
        start, stop, step = _adjust_slice(values.size, start, stop, step)
        result = []
        if step > 0
          i = start
          while i < stop
            result << values[i]
            i += step
          end
        else
          i = start
          while i > stop
            result << values[i]
            i += step
          end
        end
        String === values ? result.join : result
      end

      def _adjust_slice(length, start, stop, step)
        if step.nil?
          step = 1
        elsif step == 0
          raise Errors::RuntimeError, 'slice step cannot be 0'
        end

        if start.nil?
          start = step < 0 ? length - 1 : 0
        else
          start = _adjust_endpoint(length, start, step)
        end

        if stop.nil?
          stop = step < 0 ? -1 : length
        else
          stop = _adjust_endpoint(length, stop, step)
        end

        [start, stop, step]
      end

      def _adjust_endpoint(length, endpoint, step)
        if endpoint < 0
          endpoint += length
          endpoint = 0 if endpoint < 0
          endpoint
        elsif endpoint >= length
          step < 0 ? length - 1 : length
        else
          endpoint
        end
      end

    end
  end
end
