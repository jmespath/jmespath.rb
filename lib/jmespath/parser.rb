require 'set'

module JMESPath
  # @api private
  class Parser

    # @api private
    AFTER_DOT = Set.new([
        :identifier,        # foo.bar
        :quoted_identifier, # foo."bar"
        :star,              # foo.*
        :lbrace,            # foo[1]
        :lbracket,          # foo{a: 0}
        :function,          # foo.*.to_string(@)
        :filter,            # foo.[?bar==10]
    ])

    CURRENT_NODE = Nodes::Current.new

    # @option options [Lexer] :lexer
    def initialize(options = {})
      @lexer = options[:lexer] || Lexer.new()
    end

    # @param [String<JMESPath>] expression
    def parse(expression)
      stream = TokenStream.new(expression, @lexer.tokenize(expression))
      result = expr(stream)
      if stream.token.type != :eof
        raise Errors::SyntaxError, "expected :eof got #{stream.token.type}"
      else
        result
      end
    end

    # @api private
    def method_missing(method_name, *args)
      if matches = method_name.match(/^(nud_|led_)(.*)/)
        raise Errors::SyntaxError, "unexpected token #{matches[2]}"
      else
        super
      end
    end

    private

    # @param [TokenStream] stream
    # @param [Integer] rbp Right binding power
    def expr(stream, rbp = 0)
      left = send("nud_#{stream.token.type}", stream)
      while rbp < stream.token.binding_power
        left = send("led_#{stream.token.type}", stream, left)
      end
      left
    end

    def nud_current(stream)
      stream.next
      CURRENT_NODE
    end

    def nud_expref(stream)
      stream.next
      Nodes::Expression.new(expr(stream, 2))
    end

    def nud_filter(stream)
      led_filter(stream, CURRENT_NODE)
    end

    def nud_flatten(stream)
      led_flatten(stream, CURRENT_NODE)
    end

    def nud_identifier(stream)
      token = stream.token
      n = stream.next
      if n.type == :lparen
        Nodes::Function::FunctionName.new(token.value)
      else
        Nodes::Field.new(token.value)
      end
    end

    def nud_lbrace(stream)
      valid_keys = Set.new([:quoted_identifier, :identifier])
      stream.next(match:valid_keys)
      pairs = []
      begin
        pairs << parse_key_value_pair(stream)
        if stream.token.type == :comma
          stream.next(match:valid_keys)
        end
      end while stream.token.type != :rbrace
      stream.next
      Nodes::MultiSelectHash.new(pairs)
    end

    def nud_lbracket(stream)
      stream.next
      type = stream.token.type
      if type == :number || type == :colon
        parse_array_index_expression(stream)
      elsif type == :star && stream.lookahead(1).type == :rbracket
        parse_wildcard_array(stream)
      else
        parse_multi_select_list(stream)
      end
    end

    def nud_literal(stream)
      value = stream.token.value
      stream.next
      Nodes::Literal.new(value)
    end

    def nud_quoted_identifier(stream)
      token = stream.token
      next_token = stream.next
      if next_token.type == :lparen
        msg = 'quoted identifiers are not allowed for function names'
        raise Errors::SyntaxError, msg
      else
        Nodes::Field.new(token[:value])
      end
    end

    def nud_star(stream)
      parse_wildcard_object(stream, CURRENT_NODE)
    end

    def led_comparator(stream, left)
      token = stream.token
      stream.next
      right = expr(stream)
      Nodes::Comparator.new(left, right, token.value)
    end

    def led_dot(stream, left)
      stream.next(match:AFTER_DOT)
      if stream.token.type == :star
        parse_wildcard_object(stream, left)
      else
        children = [left, parse_dot(stream, Token::BINDING_POWER[:dot])]
        Nodes::Subexpression.new(children)
      end
    end

    def led_filter(stream, left)
      stream.next
      expression = expr(stream)
      if stream.token.type != :rbracket
        raise Errors::SyntaxError, 'expected a closing rbracket for the filter'
      end
      stream.next
      rhs = parse_projection(stream, Token::BINDING_POWER[:filter])
      children = [
        left ? left : CURRENT_NODE,
        Nodes::Condition.new(expression, rhs)
      ]
      Nodes::Projection.new(children, :array)
    end

    def led_flatten(stream, left)
      stream.next
      children = [
        Nodes::Flatten.new(left),
        parse_projection(stream, Token::BINDING_POWER[:flatten])
      ]
      Nodes::Projection.new(children, :array)
    end

    def led_lbracket(stream, left)
      stream.next(match: Set.new([:number, :colon, :star]))
      type = stream.token.type
      if type == :number || type == :colon
        children = [
          left,
          parse_array_index_expression(stream)
        ]
        Nodes::Subexpression.new(children)
      else
        parse_wildcard_array(stream, left)
      end
    end

    def led_lparen(stream, left)
      args = []
      name = left.name
      stream.next
      while stream.token.type != :rparen
        args << expr(stream, 0)
        if stream.token.type == :comma
          stream.next
        end
      end
      stream.next
      Nodes::Function.new(args, name)
    end

    def led_or(stream, left)
      stream.next
      children = [left, expr(stream, Token::BINDING_POWER[:or])]
      Nodes::Or.new(children)
    end

    def led_pipe(stream, left)
      stream.next
      children = [left, expr(stream, Token::BINDING_POWER[:pipe])]
      Nodes::Pipe.new(children)
    end

    def parse_array_index_expression(stream)
      pos = 0
      parts = [nil, nil, nil]
      begin
        if stream.token.type == :colon
          pos += 1
        else
          parts[pos] = stream.token.value
        end
        stream.next(match:Set.new([:number, :colon, :rbracket]))
      end while stream.token.type != :rbracket
      stream.next
      if pos == 0
        Nodes::Index.new(parts[0])
      elsif pos > 2
        raise Errors::SyntaxError, 'invalid array slice syntax: too many colons'
      else
        Nodes::Slice.new(parts)
      end
    end

    def parse_dot(stream, binding_power)
      if stream.token.type == :lbracket
        stream.next
        parse_multi_select_list(stream)
      else
        expr(stream, binding_power)
      end
    end

    def parse_key_value_pair(stream)
      key = stream.token.value
      stream.next(match:Set.new([:colon]))
      stream.next
      Nodes::MultiSelectHash::KeyValuePair.new([expr(stream)], key)
    end

    def parse_multi_select_list(stream)
      nodes = []
      begin
        nodes << expr(stream)
        if stream.token.type == :comma
          stream.next
          if stream.token.type == :rbracket
            raise Errors::SyntaxError, 'expression epxected, found rbracket'
          end
        end
      end while stream.token.type != :rbracket
      stream.next
      Nodes::MultiSelectList.new(nodes)
    end

    def parse_projection(stream, binding_power)
      type = stream.token.type
      if stream.token.binding_power < 10
        CURRENT_NODE
      elsif type == :dot
        stream.next(match:AFTER_DOT)
        parse_dot(stream, binding_power)
      elsif type == :lbracket || type == :filter
        expr(stream, binding_power)
      else
        raise Errors::SyntaxError, 'syntax error after projection'
      end
    end

    def parse_wildcard_array(stream, left = nil)
      stream.next(match:Set.new([:rbracket]))
      stream.next
      children = [
        left ? left : CURRENT_NODE,
        parse_projection(stream, Token::BINDING_POWER[:star])
      ]
      Nodes::Projection.new(children, :array)
    end

    def parse_wildcard_object(stream, left = nil)
      stream.next
      children = [
        left ? left : CURRENT_NODE,
        parse_projection(stream, Token::BINDING_POWER[:star])
      ]
      Nodes::Projection.new(children, :object)
    end

  end
end
