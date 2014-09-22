require 'multi_json'

module JMESPath
  class Lexer

    # @api private
    TOKEN_PATTERNS = {}

    # @api private
    TOKEN_TYPES = {}

    {
      '[a-zA-Z_][a-zA-Z_0-9]*'     => :identifier,
      '\.'                         => :dot,
      '\*'                         => :star,
      '\[\]'                       => :flatten,
      '-?\d+'                      => :number,
      '\|\|'                       => :or,
      '\|'                         => :pipe,
      '\[\?'                       => :filter,
      '\['                         => :lbracket,
      '\]'                         => :rbracket,
      '"(?:\\\\\\\\|\\\\"|[^"])*"' => :quoted_identifier,
      '`(?:\\\\\\\\|\\\\`|[^`])*`' => :literal,
      ','                          => :comma,
      ':'                          => :colon,
      '@'                          => :current,
      '&'                          => :expref,
      '\('                         => :lparen,
      '\)'                         => :rparen,
      '\{'                         => :lbrace,
      '\}'                         => :rbrace,
      '!='                         => :comparator,
      '=='                         => :comparator,
      '<='                         => :comparator,
      '>='                         => :comparator,
      '<'                          => :comparator,
      '>'                          => :comparator,
      '[ \t]'                      => :skip,
    }.each.with_index do |(pattern, type), n|
      TOKEN_PATTERNS[n] = pattern
      TOKEN_TYPES[n] = type
    end

    # @api private
    TOKEN_REGEX = /(#{TOKEN_PATTERNS.values.join(')|(')})/

    # @api private
    JSON_VALUE = /^[\["{]/

    # @api private
    JSON_NUMBER = /^\-?[0-9]*(\.[0-9]+)?([e|E][+|\-][0-9]+)?$/

    # @param [String<JMESPath>] expression
    # @return [Array<Hash>]
    def tokenize(expression)
      offset = 0
      tokens = []
      expression.scan(TOKEN_REGEX).each do |match|
        match_index = match.find_index { |token| !token.nil? }
        match_value = match[match_index]
        type = TOKEN_TYPES[match_index]
        if type != :skip
          token = { type:type, value:match_value, pos:offset }
          case type
          when :number then token_number(token, expression, offset)
          when :literal then token_literal(token, expression, offset)
          when :quoted_identifier
            token_quoted_identifier(token, expression, offset)
          end
          tokens << token
        end
        offset += match_value.size
      end
      tokens << { type:'eof', pos:offset, value:nil }
      syntax_error('invalid expression' expression, offset)
      tokens
    end

    private

    def token_number(token, expression, offset)
      token[:value] = token[:value].to_i
    end

    def token_literal(token, expression, offset)
      token[:value] =
        case token[:value]
        when 'true', 'false' then token[:value] == 'true'
        when 'null' then nil
        when '' then syntax_error("empty json literal", expression, offset)
        when JSON_VALUE then decode_json(token[:value])
        when JSON_NUMBER then decode_json(token[:value])
        else decode_json('"' + token[:value] + '"')
        end
    end

    def token_quoted_identifier(token, expression, offset)
      token[:value] = decode_json(token[:value])
    end

    def decode_json(json)
      # TODO : handle JSON parsing errors for invalid quoted identifiers
      MultiJson.load(json)
    end

    def syntax_error(message, expression, offset)
      raise Errors::SyntaxError.new(message, expression, offset)
    end

  end
end
