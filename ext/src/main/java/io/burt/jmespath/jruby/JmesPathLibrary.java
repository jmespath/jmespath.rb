package io.burt.jmespath.jruby;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyString;
import org.jruby.RubyNil;
import org.jruby.RubyBoolean;
import org.jruby.RubyHash;
import org.jruby.runtime.load.Library;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Block;
import org.jruby.runtime.Visibility;
import org.jruby.anno.JRubyModule;
import org.jruby.anno.JRubyMethod;
import org.jruby.internal.runtime.methods.CallConfiguration;
import org.jruby.internal.runtime.methods.DynamicMethod;

public class JmesPathLibrary implements Library {
  public void load(Ruby ruby, boolean wrap) {
    RubyClass jmesPathClass = JmesPath.install(ruby);
    JmesPathExpression.install(ruby, jmesPathClass);
    installErrors(ruby, jmesPathClass);
  }

  private void installErrors(Ruby ruby, RubyModule parentModule) {
    RubyClass standardErrorClass = ruby.getStandardError();
    RubyClass jmesPathError = parentModule.defineClassUnder("JMESPathError", standardErrorClass, standardErrorClass.getAllocator());
    parentModule.defineClassUnder("ParseError", jmesPathError, jmesPathError.getAllocator());
    RubyClass functionCallError = parentModule.defineClassUnder("FunctionCallError", jmesPathError, jmesPathError.getAllocator());
    parentModule.defineClassUnder("ArityError", functionCallError, functionCallError.getAllocator());
    parentModule.defineClassUnder("ArgumentTypeError", functionCallError, functionCallError.getAllocator());
  }
}
