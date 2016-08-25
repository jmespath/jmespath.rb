package io.burt.jmespath.jruby;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;

import io.burt.jmespath.Expression;

@JRubyClass(name = "JMESPath::Expression")
public class JmesPathExpression extends RubyObject {
  private final Expression<IRubyObject> expression;

  public JmesPathExpression(Ruby ruby, RubyClass type, Expression<IRubyObject> expression) {
    super(ruby, type);
    this.expression = expression;
  }

  static void install(Ruby ruby) {
    RubyClass jmesPathExpressionClass = ruby.getClassFromPath("JMESPath").defineClassUnder("Expression", ruby.getObject(), ObjectAllocator.NOT_ALLOCATABLE_ALLOCATOR);
    jmesPathExpressionClass.defineAnnotatedMethods(JmesPathExpression.class);
  }

  static IRubyObject create(Ruby ruby, Expression<IRubyObject> expression) {
    return new JmesPathExpression(ruby, (RubyClass) ruby.getClassFromPath("JMESPath::Expression"), expression);
  }

  @JRubyMethod
  public IRubyObject search(ThreadContext ctx, IRubyObject target) {
    return expression.search(target);
  }
}
