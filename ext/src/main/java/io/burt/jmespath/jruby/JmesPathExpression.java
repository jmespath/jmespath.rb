package io.burt.jmespath.jruby;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;

import io.burt.jmespath.Expression;
import io.burt.jmespath.function.ArityException;
import io.burt.jmespath.function.ArgumentTypeException;

@JRubyClass(name = "JMESPath::Expression")
public class JmesPathExpression extends RubyObject {
  private final Expression<IRubyObject> expression;
  private final RubyClass arityErrorClass;
  private final RubyClass argumentTypeErrorClass;

  public JmesPathExpression(Ruby ruby, RubyClass type, Expression<IRubyObject> expression) {
    super(ruby, type);
    this.expression = expression;
    this.arityErrorClass = (RubyClass) ruby.getClassFromPath("JMESPath::ArityError");
    this.argumentTypeErrorClass = (RubyClass) ruby.getClassFromPath("JMESPath::ArgumentTypeError");
  }

  static RubyClass install(Ruby ruby, RubyModule parentModule) {
    RubyClass jmesPathExpressionClass = parentModule.defineClassUnder("Expression", ruby.getObject(), ObjectAllocator.NOT_ALLOCATABLE_ALLOCATOR);
    jmesPathExpressionClass.defineAnnotatedMethods(JmesPathExpression.class);
    return jmesPathExpressionClass;
  }

  static IRubyObject create(Ruby ruby, Expression<IRubyObject> expression) {
    return new JmesPathExpression(ruby, (RubyClass) ruby.getClassFromPath("JMESPath::Expression"), expression);
  }

  @JRubyMethod
  public IRubyObject search(ThreadContext ctx, IRubyObject target) {
    try {
      return expression.search(target);
    } catch (ArityException ae) {
      throw ctx.runtime.newRaiseException(arityErrorClass, ae.getMessage());
    } catch (ArgumentTypeException ate) {
      throw ctx.runtime.newRaiseException(argumentTypeErrorClass, ate.getMessage());
    }
  }
}
