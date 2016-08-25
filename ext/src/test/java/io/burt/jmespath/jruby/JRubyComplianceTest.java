package io.burt.jmespath.jruby;

import org.jruby.Ruby;
import org.jruby.runtime.builtin.IRubyObject;

import io.burt.jmespath.JmesPathComplianceTest;
import io.burt.jmespath.Adapter;

public class JRubyComplianceTest extends JmesPathComplianceTest<IRubyObject> {
  private static final Ruby ruby = Ruby.newInstance();
  private final Adapter<IRubyObject> runtime = new JRubyRuntime(ruby);

  @Override
  protected Adapter<IRubyObject> runtime() { return runtime; }
}
