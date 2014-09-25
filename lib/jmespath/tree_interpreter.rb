module JMESPath
  class TreeInterpreter

    def visit(node, data)
      dispatch(node, data)
    end

    private

    def dispatch(node, value)
      case node[:type]

      when :field
        if hash_like?(value)
          value[node[:key]]
        else
          nil
        end

      when :subexpression
        dispatch(node[:children][1], dispatch(node[:children][0], value))

      when :index
        if array_like?(value)
          value[node[:index]]
        else
          nil
        end

      when :projection
        # Interprets a projection node, passing the values of the left
        # child through the values of the right child and aggregating
        # the non-null results into the return value.
        left = dispatch(node[:children][0], value)
        if node[:from] == :object && hash_like?(left)
          projection(left.values, node)
        elsif node[:from] == :object && left == []
          projection(left, node)
        elsif node[:from] == :array && array_like?(left)
          projection(left, node)
        else
          nil
        end

      when :flatten
        value = dispatch(node[:children][0], value)
        if array_like?(value)
          value.inject([]) do |values, v|
            values + (array_like?(v) ? v : [v])
          end
        else
          nil
        end

      when :literal
        node[:value]

      when :current
        value

      when :or
        result = dispatch(node[:children][0], value)
        if result.nil? or result.empty?
          dispatch(node[:children][1], value)
        else
          result
        end

      when :pipe
        dispatch(node[:children][1], dispatch(node[:children][0], value))

      when :multi_select_list
        if value.nil?
          value
        else
          node[:children].map { |n| dispatch(n, value) }
        end

      when :multi_select_hash
        if value.nil?
          nil
        else
          node[:children].each.with_object({}) do |child, hash|
            hash[child[:key]] = dispatch(child[:children][0], value)
          end
        end


      when :comparator
        left = dispatch(node[:children][0], value)
        right = dispatch(node[:children][1], value)
        case node[:relation]
        when '==' then compare_values(left, right)
        when '!=' then !compare_values(left, right)
        when '>' then is_int(left) && is_int(right) && left > right
        when '>=' then is_int(left) && is_int(right) && left >= right
        when '<' then is_int(left) && is_int(right) && left < right
        when '<=' then is_int(left) && is_int(right) && left <= right
        end

      when :condition
        raise NotImplementedError

      when :function
        args = node[:children].map { |child| dispatch(child, value) }
        send("function_#{node[:fn]}", *args)

      when :slice
        function_slice(value, *node[:args])

      when :expression
        raise NotImplementedError

      else
        raise NotImplementedError
      end
    end

    def hash_like?(value)
      Hash === value || Struct === value
    end

    def array_like?(value)
      Array === value
    end

    def projection(values, node)
      values.inject([]) do |list, v|
        list << dispatch(node[:children][1], v)
      end.compact
    end

    def function_sort(values)
      values.sort
    end

    def function_slice(values, *args)
puts "VALUES: #{values.inspect}"
      if String === values || array_like?(values)
        _slice(values, *args)
      else
        nil
      end
    end

    def _slice(values, start, stop, step)
      start, stop, step = _adjust_slice(values.size, start, stop, step)
      result = []
puts ''
puts [values, start, stop, step].inspect
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

    def compare_values(a, b)
      if a == b
        true
      else
        false
      end
    end

    def is_int(value)
      Integer === value
    end

  end
end
