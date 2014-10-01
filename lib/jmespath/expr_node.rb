module JMESPath
  class ExprNode

    def initialize(interpreter, node)
      @intepreter = interpreter
      @node = node
    end

    attr_reader :interpreter

    attr_reader :node

  end
end
