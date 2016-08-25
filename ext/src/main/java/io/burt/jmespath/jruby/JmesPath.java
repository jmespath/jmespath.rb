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
import io.burt.jmespath.parser.ParseException;

@JRubyClass(name = "JMESPath")
public class JmesPath extends RubyObject {
  private final JRubyRuntime jmespath;
  private final RubyClass parseErrorClass;

  public JmesPath(Ruby ruby, RubyClass type) {
    super(ruby, type);
    this.jmespath = new JRubyRuntime(ruby);
    this.parseErrorClass = (RubyClass) ruby.getClassFromPath("JMESPath::ParseError");
  }

  private static class JmesPathAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby ruby, RubyClass type) {
      return new JmesPath(ruby, type);
    }
  }

  static RubyClass install(Ruby ruby) {
    RubyClass jmesPathClass = ruby.defineClass("JMESPath", ruby.getObject(), new JmesPathAllocator());
    jmesPathClass.defineAnnotatedMethods(JmesPath.class);
    return jmesPathClass;
  }

  @JRubyMethod
  public IRubyObject compile(ThreadContext ctx, IRubyObject expression) {
    try {
      return JmesPathExpression.create(ctx.runtime, jmespath.compile(expression.toString()));
    } catch (ParseException pe) {
      throw ctx.runtime.newRaiseException(parseErrorClass, pe.getMessage());
    }
  }
}
