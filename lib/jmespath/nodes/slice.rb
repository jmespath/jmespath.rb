module JMESPath
  # @api private
  module Nodes
    class Slice < Leaf
      def initialize(args)
        @args = args
      end

      def visit(value)
        if String === value || Array === value
          start, stop, step = adjust_slice(value.size, *@args)
          result = []
          if step > 0
            i = start
            while i < stop
              result << value[i]
              i += step
            end
          else
            i = start
            while i > stop
              result << value[i]
              i += step
            end
          end
          String === value ? result.join : result
        else
          nil
        end
      end

      def to_h
        {
          :type => :slice,
          :args => @args,
        }
      end

      private

      def adjust_slice(length, start, stop, step)
        if step.nil?
          step = 1
        elsif step == 0
          raise Errors::RuntimeError, 'slice step cannot be 0'
        end

        if start.nil?
          start = step < 0 ? length - 1 : 0
        else
          start = adjust_endpoint(length, start, step)
        end

        if stop.nil?
          stop = step < 0 ? -1 : length
        else
          stop = adjust_endpoint(length, stop, step)
        end

        [start, stop, step]
      end

      def adjust_endpoint(length, endpoint, step)
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
