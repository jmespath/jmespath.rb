module JMESPath
  # @api private
  module Nodes
    class Function < Node

      FUNCTIONS = {}

      def initialize(children)
        @children = children
      end

      def self.create(name, children)
        if (type = FUNCTIONS[name])
          type.new(children)
        else
          raise Errors::UnknownFunctionError, "unknown function #{name}()"
        end
      end

      def visit(value)
        call(@children.map { |child| child.visit(value) })
      end

      def optimize
        self.class.new(@children.map(&:optimize))
      end

      class FunctionName
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end

      private

      def call(args)
        nil
      end
    end

    module TypeChecker
      def get_type(value)
        case value
        when String then STRING_TYPE
        when true, false then BOOLEAN_TYPE
        when nil then NULL_TYPE
        when Numeric then NUMBER_TYPE
        when Hash, Struct then OBJECT_TYPE
        when Array then ARRAY_TYPE
        when Expression then EXPRESSION_TYPE
        end
      end

      ARRAY_TYPE = 0
      BOOLEAN_TYPE = 1
      EXPRESSION_TYPE = 2
      NULL_TYPE = 3
      NUMBER_TYPE = 4
      OBJECT_TYPE = 5
      STRING_TYPE = 6

      TYPE_NAMES = {
        ARRAY_TYPE => 'array',
        BOOLEAN_TYPE => 'boolean',
        EXPRESSION_TYPE => 'expression',
        NULL_TYPE => 'null',
        NUMBER_TYPE => 'number',
        OBJECT_TYPE => 'object',
        STRING_TYPE => 'string',
      }.freeze
    end

    class AbsFunction < Function
      FUNCTIONS['abs'] = self

      def call(args)
        if args.count == 1
          value = args.first
        else
          raise Errors::InvalidArityError, "function abs() expects one argument"
        end
        if Numeric === value
          value.abs
        else
          raise Errors::InvalidTypeError, "function abs() expects a number"
        end
      end
    end

    class AvgFunction < Function
      FUNCTIONS['avg'] = self

      def call(args)
        if args.count == 1
          values = args.first
        else
          raise Errors::InvalidArityError, "function avg() expects one argument"
        end
        if Array === values
          values.inject(0) do |total,n|
            if Numeric === n
              total + n
            else
              raise Errors::InvalidTypeError, "function avg() expects numeric values"
            end
          end / values.size.to_f
        else
          raise Errors::InvalidTypeError, "function avg() expects a number"
        end
      end
    end

    class CeilFunction < Function
      FUNCTIONS['ceil'] = self

      def call(args)
        if args.count == 1
          value = args.first
        else
          raise Errors::InvalidArityError, "function ceil() expects one argument"
        end
        if Numeric === value
          value.ceil
        else
          raise Errors::InvalidTypeError, "function ceil() expects a numeric value"
        end
      end
    end

    class ContainsFunction < Function
      FUNCTIONS['contains'] = self

      def call(args)
        if args.count == 2
          haystack = args[0]
          needle = args[1]
          if String === haystack || Array === haystack
            haystack.include?(needle)
          else
            raise Errors::InvalidTypeError, "contains expects 2nd arg to be a list"
          end
        else
          raise Errors::InvalidArityError, "function contains() expects 2 arguments"
        end
      end
    end

    class FloorFunction < Function
      FUNCTIONS['floor'] = self

      def call(args)
        if args.count == 1
          value = args.first
        else
          raise Errors::InvalidArityError, "function floor() expects one argument"
        end
        if Numeric === value
          value.floor
        else
          raise Errors::InvalidTypeError, "function floor() expects a numeric value"
        end
      end
    end

    class LengthFunction < Function
      FUNCTIONS['length'] = self

      def call(args)
        if args.count == 1
          value = args.first
        else
          raise Errors::InvalidArityError, "function length() expects one argument"
        end
        case value
        when Hash, Array, String then value.size
        else raise Errors::InvalidTypeError, "function length() expects string, array or object"
        end
      end
    end

    class MaxFunction < Function
      include TypeChecker

      FUNCTIONS['max'] = self

      def call(args)
        if args.count == 1
          values = args.first
        else
          raise Errors::InvalidArityError, "function max() expects one argument"
        end
        if Array === values
          return nil if values.empty?
          first = values.first
          first_type = get_type(first)
          unless first_type == NUMBER_TYPE || first_type == STRING_TYPE
            msg = "function max() expects numeric or string values"
            raise Errors::InvalidTypeError, msg
          end
          values.inject([first, first_type]) do |(max, max_type), v|
            v_type = get_type(v)
            if max_type == v_type
              v > max ? [v, v_type] : [max, max_type]
            else
              msg = "function max() encountered a type mismatch in sequence: "
              msg << "#{max_type}, #{v_type}"
              raise Errors::InvalidTypeError, msg
            end
          end.first
        else
          raise Errors::InvalidTypeError, "function max() expects an array"
        end
      end
    end

    class MinFunction < Function
      include TypeChecker

      FUNCTIONS['min'] = self

      def call(args)
        if args.count == 1
          values = args.first
        else
          raise Errors::InvalidArityError, "function min() expects one argument"
        end
        if Array === values
          return nil if values.empty?
          first = values.first
          first_type = get_type(first)
          unless first_type == NUMBER_TYPE || first_type == STRING_TYPE
            msg = "function min() expects numeric or string values"
            raise Errors::InvalidTypeError, msg
          end
          values.inject([first, first_type]) do |(min, min_type), v|
            v_type = get_type(v)
            if min_type == v_type
              v < min ? [v, v_type] : [min, min_type]
            else
              msg = "function min() encountered a type mismatch in sequence: "
              msg << "#{min_type}, #{v_type}"
              raise Errors::InvalidTypeError, msg
            end
          end.first
        else
          raise Errors::InvalidTypeError, "function min() expects an array"
        end
      end
    end

    class TypeFunction < Function
      include TypeChecker

      FUNCTIONS['type'] = self

      def call(args)
        if args.count == 1
          TYPE_NAMES[get_type(args.first)]
        else
          raise Errors::InvalidArityError, "function type() expects one argument"
        end
      end
    end

    class KeysFunction < Function
      FUNCTIONS['keys'] = self

      def call(args)
        if args.count == 1
          value = args.first
          if hash_like?(value)
            case value
            when Hash then value.keys.map(&:to_s)
            when Struct then value.members.map(&:to_s)
            else raise NotImplementedError
            end
          else
            raise Errors::InvalidTypeError, "function keys() expects a hash"
          end
        else
          raise Errors::InvalidArityError, "function keys() expects one argument"
        end
      end
    end

    class ValuesFunction < Function
      FUNCTIONS['values'] = self

      def call(args)
        if args.count == 1
          value = args.first
          if hash_like?(value)
            value.values
          elsif Array === value
            value
          else
            raise Errors::InvalidTypeError, "function values() expects an array or a hash"
          end
        else
          raise Errors::InvalidArityError, "function values() expects one argument"
        end
      end
    end

    class JoinFunction < Function
      FUNCTIONS['join'] = self

      def call(args)
        if args.count == 2
          glue = args[0]
          values = args[1]
          if !(String === glue)
            raise Errors::InvalidTypeError, "function join() expects the first argument to be a string"
          elsif Array === values && values.all? { |v| String === v }
            values.join(glue)
          else
            raise Errors::InvalidTypeError, "function join() expects values to be an array of strings"
          end
        else
          raise Errors::InvalidArityError, "function join() expects an array of strings"
        end
      end
    end

    class ToStringFunction < Function
      FUNCTIONS['to_string'] = self

      def call(args)
        if args.count == 1
          value = args.first
          String === value ? value : JSON.dump(value)
        else
          raise Errors::InvalidArityError, "function to_string() expects one argument"
        end
      end
    end

    class ToNumberFunction < Function
      FUNCTIONS['to_number'] = self

      def call(args)
        if args.count == 1
          begin
            value = Float(args.first)
            Integer(value) === value ? value.to_i : value
          rescue
            nil
          end
        else
          raise Errors::InvalidArityError, "function to_number() expects one argument"
        end
      end
    end

    class SumFunction < Function
      FUNCTIONS['sum'] = self

      def call(args)
        if args.count == 1 && Array === args.first
          args.first.inject(0) do |sum,n|
            if Numeric === n
              sum + n
            else
              raise Errors::InvalidTypeError, "function sum() expects values to be numeric"
            end
          end
        else
          raise Errors::InvalidArityError, "function sum() expects one argument"
        end
      end
    end

    class NotNullFunction < Function
      FUNCTIONS['not_null'] = self

      def call(args)
        if args.count > 0
          args.find { |value| !value.nil? }
        else
          raise Errors::InvalidArityError, "function not_null() expects one or more arguments"
        end
      end
    end

    class SortFunction < Function
      include TypeChecker

      FUNCTIONS['sort'] = self

      def call(args)
        if args.count == 1
          value = args.first
          if Array === value
            value.sort do |a, b|
              a_type = get_type(a)
              b_type = get_type(b)
              if (a_type == STRING_TYPE || a_type == NUMBER_TYPE) && a_type == b_type
                a <=> b
              else
                raise Errors::InvalidTypeError, "function sort() expects values to be an array of numbers or integers"
              end
            end
          else
            raise Errors::InvalidTypeError, "function sort() expects values to be an array of numbers or integers"
          end
        else
          raise Errors::InvalidArityError, "function sort() expects one argument"
        end
      end
    end

    class SortByFunction < Function
      include TypeChecker

      FUNCTIONS['sort_by'] = self

      def call(args)
        if args.count == 2
          if get_type(args[0]) == ARRAY_TYPE && get_type(args[1]) == EXPRESSION_TYPE
            values = args[0]
            expression = args[1]
            values.sort do |a,b|
              a_value = expression.eval(a)
              b_value = expression.eval(b)
              a_type = get_type(a_value)
              b_type = get_type(b_value)
              if (a_type == STRING_TYPE || a_type == NUMBER_TYPE) && a_type == b_type
                a_value <=> b_value
              else
                raise Errors::InvalidTypeError, "function sort() expects values to be an array of numbers or integers"
              end
            end
          else
            raise Errors::InvalidTypeError, "function sort_by() expects an array and an expression"
          end
        else
          raise Errors::InvalidArityError, "function sort_by() expects two arguments"
        end
      end
    end

    module CompareBy
      include TypeChecker

      def compare_by(mode, *args)
        if args.count == 2
          values = args[0]
          expression = args[1]
          if get_type(values) == ARRAY_TYPE && get_type(expression) == EXPRESSION_TYPE
            type = get_type(expression.eval(values.first))
            if type != NUMBER_TYPE && type != STRING_TYPE
              msg = "function #{mode}() expects values to be strings or numbers"
              raise Errors::InvalidTypeError, msg
            end
            values.send(mode) do |entry|
              value = expression.eval(entry)
              value_type = get_type(value)
              if value_type != type
                msg = "function #{mode}() encountered a type mismatch in "
                msg << "sequence: #{type}, #{value_type}"
                raise Errors::InvalidTypeError, msg
              end
              value
            end
          else
            msg = "function #{mode}() expects an array and an expression"
            raise Errors::InvalidTypeError, msg
          end
        else
          msg = "function #{mode}() expects two arguments"
          raise Errors::InvalidArityError, msg
        end
      end
    end

    class MaxByFunction < Function
      include CompareBy

      FUNCTIONS['max_by'] = self

      def call(args)
        compare_by(:max_by, *args)
      end
    end

    class MinByFunction < Function
      include CompareBy

      FUNCTIONS['min_by'] = self

      def call(args)
        compare_by(:min_by, *args)
      end
    end

    class EndsWithFunction < Function
      include TypeChecker

      FUNCTIONS['ends_with'] = self

      def call(args)
        if args.count == 2
          search, suffix = args
          search_type = get_type(search)
          suffix_type = get_type(suffix)
          if search_type != STRING_TYPE
            msg = "function ends_with() expects first argument to be a string"
            raise Errors::InvalidTypeError, msg
          end
          if suffix_type != STRING_TYPE
            msg = "function ends_with() expects second argument to be a string"
            raise Errors::InvalidTypeError, msg
          end
          search.end_with?(suffix)
        else
          msg = "function ends_with() expects two arguments"
          raise Errors::InvalidArityError, msg
        end
      end
    end

    class StartsWithFunction < Function
      include TypeChecker

      FUNCTIONS['starts_with'] = self

      def call(args)
        if args.count == 2
          search, prefix = args
          search_type = get_type(search)
          prefix_type = get_type(prefix)
          if search_type != STRING_TYPE
            msg = "function starts_with() expects first argument to be a string"
            raise Errors::InvalidTypeError, msg
          end
          if prefix_type != STRING_TYPE
            msg = "function starts_with() expects second argument to be a string"
            raise Errors::InvalidTypeError, msg
          end
          search.start_with?(prefix)
        else
          msg = "function starts_with() expects two arguments"
          raise Errors::InvalidArityError, msg
        end
      end
    end

    class MergeFunction < Function
      FUNCTIONS['merge'] = self

      def call(args)
        if args.count == 0
          msg = "function merge() expects 1 or more arguments"
          raise Errors::InvalidArityError, msg
        end
        args.inject({}) do |h, v|
          h.merge(v)
        end
      end
    end

    class ReverseFunction < Function
      FUNCTIONS['reverse'] = self

      def call(args)
        if args.count == 0
          msg = "function reverse() expects 1 or more arguments"
          raise Errors::InvalidArityError, msg
        end
        value = args.first
        if Array === value || String === value
          value.reverse
        else
          msg = "function reverse() expects an array or string"
          raise Errors::InvalidTypeError, msg
        end
      end
    end

    class ToArrayFunction < Function
      FUNCTIONS['to_array'] = self

      def call(args)
        value = args.first
        Array === value ? value : [value]
      end
    end
  end
end
