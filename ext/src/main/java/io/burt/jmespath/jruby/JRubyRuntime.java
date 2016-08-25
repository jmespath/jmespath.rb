package io.burt.jmespath.jruby;

import java.util.List;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyString;
import org.jruby.RubyBoolean;
import org.jruby.RubyNumeric;
import org.jruby.RubyInteger;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.runtime.builtin.IRubyObject;

import io.burt.jmespath.BaseRuntime;
import io.burt.jmespath.JmesPathType;

public class JRubyRuntime extends BaseRuntime<IRubyObject> {
  private final Ruby ruby;

  public JRubyRuntime(Ruby ruby) {
    this.ruby = ruby;
  }

  private RubyModule json() {
    ruby.getLoadService().require("json");
    return ruby.getClassFromPath("JSON");
  }

  @Override
  public IRubyObject parseString(String string) {
    return json().callMethod(ruby.getCurrentContext(), "load", ruby.newString(string));
  }

  @Override
  @SuppressWarnings("unchecked")
  public List<IRubyObject> toList(IRubyObject value) {
    if (value instanceof RubyArray) {
      RubyArray array = (RubyArray) value;
      return (List<IRubyObject>) array.getList();
    } else if (value instanceof RubyHash) {
      RubyHash hash = (RubyHash) value;
      return (List<IRubyObject>) hash.rb_values().getList();
    } else {
      return Collections.emptyList();
    }
  }

  @Override
  public String toString(IRubyObject value) {
    if (value instanceof RubyString) {
      return value.asJavaString();
    } else {
      return json().callMethod(ruby.getCurrentContext(), "dump", value).toString();
    }
  }

  @Override
  public Number toNumber(IRubyObject value) {
    if (value instanceof RubyInteger) {
      return ((RubyInteger) value).getLongValue();
    } else if (value instanceof RubyNumeric) {
      return ((RubyNumeric) value).getDoubleValue();
    } else {
      return null;
    }
  }

  @Override
  public JmesPathType typeOf(IRubyObject value) {
    if (value != null && value.isNil()) {
      return JmesPathType.NULL;
    } else if (value instanceof RubyString) {
      return JmesPathType.STRING;
    } else if (value instanceof RubyNumeric) {
      return JmesPathType.NUMBER;
    } else if (value instanceof RubyBoolean) {
      return JmesPathType.BOOLEAN;
    } else if (value instanceof RubyArray) {
      return JmesPathType.ARRAY;
    } else if (value instanceof RubyHash) {
      return JmesPathType.OBJECT;
    } else {
      throw new IllegalStateException(String.format("Unknown node type encountered: %s", value.getClass().getName()));
    }
  }

  @Override
  public boolean isTruthy(IRubyObject value) {
    switch (typeOf(value)) {
      case NULL:
        return false;
      case NUMBER:
        return true;
      case BOOLEAN:
        return value.isTrue();
      case ARRAY:
        return !((RubyArray) value).isEmpty();
      case OBJECT:
        return !((RubyHash) value).isEmpty();
      case STRING:
        return !((RubyString) value).isEmpty();
      default:
        throw new IllegalStateException(String.format("Unknown node type encountered: %s", value.getClass().getName()));
    }
  }

  @Override
  public IRubyObject getProperty(IRubyObject value, String name) {
    return getProperty(value, ruby.newString(name));
  }

  @Override
  public IRubyObject getProperty(IRubyObject value, IRubyObject name) {
    if (value instanceof RubyHash) {
      IRubyObject result = ((RubyHash) value).fastARef(name);
      return result == null ? ruby.getNil() : result;
    } else {
      return ruby.getNil();
    }
  }

  @Override
  @SuppressWarnings("unchecked")
  public Collection<IRubyObject> getPropertyNames(IRubyObject value) {
    if (value instanceof RubyHash) {
      RubyHash hash = (RubyHash) value;
      return (Collection<IRubyObject>) hash.keys().getList();
    } else {
      return Collections.emptyList();
    }
  }

  @Override
  public IRubyObject createNull() {
    return ruby.getNil();
  }

  private static final IRubyObject[] RUBY_OBJECT_ARRAY_TYPE = new IRubyObject[] {};

  @Override
  public IRubyObject createArray(Collection<IRubyObject> elements) {
    return ruby.newArray(elements.toArray(RUBY_OBJECT_ARRAY_TYPE));
  }

  @Override
  public IRubyObject createString(String str) {
    return ruby.newString(str);
  }

  @Override
  public IRubyObject createBoolean(boolean b) {
    return b ? ruby.getTrue() : ruby.getFalse();
  }

  @Override
  public IRubyObject createObject(Map<IRubyObject, IRubyObject> obj) {
    return RubyHash.newHash(ruby, obj, ruby.getNil());
  }

  @Override
  public IRubyObject createNumber(double n) {
    return ruby.newFloat(n);
  }

  @Override
  public IRubyObject createNumber(long n) {
    return ruby.newFixnum(n);
  }
}
