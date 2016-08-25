package io.burt.jmespath.jruby;

import java.util.List;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;

import org.jruby.Ruby;
import org.jruby.RubyObject;
import org.jruby.RubyModule;
import org.jruby.RubyString;
import org.jruby.RubyBoolean;
import org.jruby.RubyNumeric;
import org.jruby.RubyInteger;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.runtime.ClassIndex;
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
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    if (nativeTypeIndex == ClassIndex.ARRAY) {
      RubyArray array = (RubyArray) value;
      return (List<IRubyObject>) array.getList();
    } else if (nativeTypeIndex == ClassIndex.HASH) {
      RubyHash hash = (RubyHash) value;
      return (List<IRubyObject>) hash.rb_values().getList();
    } else {
      return Collections.emptyList();
    }
  }

  @Override
  public String toString(IRubyObject value) {
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    if (nativeTypeIndex == ClassIndex.STRING) {
      return value.asJavaString();
    } else {
      return json().callMethod(ruby.getCurrentContext(), "dump", value).toString();
    }
  }

  @Override
  public Number toNumber(IRubyObject value) {
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    switch (nativeTypeIndex) {
      case ClassIndex.FIXNUM:
      case ClassIndex.INTEGER:
        return ((RubyNumeric) value).getLongValue();
      case ClassIndex.FLOAT:
      case ClassIndex.NUMERIC:
        return ((RubyNumeric) value).getDoubleValue();
      default:
        return null;
    }
  }

  @Override
  public JmesPathType typeOf(IRubyObject value) {
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    switch (nativeTypeIndex) {
      case ClassIndex.NIL:
        return JmesPathType.NULL;
      case ClassIndex.TRUE:
      case ClassIndex.FALSE:
        return JmesPathType.BOOLEAN;
      case ClassIndex.FIXNUM:
      case ClassIndex.FLOAT:
      case ClassIndex.INTEGER:
      case ClassIndex.NUMERIC:
        return JmesPathType.NUMBER;
      case ClassIndex.STRING:
        return JmesPathType.STRING;
      case ClassIndex.ARRAY:
        return JmesPathType.ARRAY;
      case ClassIndex.HASH:
        return JmesPathType.OBJECT;
      default:
        throw new IllegalStateException(String.format("Unknown node type encountered: %s", value.getClass().getName()));
    }
  }

  @Override
  public boolean isTruthy(IRubyObject value) {
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    switch (nativeTypeIndex) {
      case ClassIndex.NIL:
      case ClassIndex.FALSE:
        return false;
      case ClassIndex.FIXNUM:
      case ClassIndex.FLOAT:
      case ClassIndex.INTEGER:
      case ClassIndex.NUMERIC:
      case ClassIndex.TRUE:
        return true;
      case ClassIndex.STRING:
        return !((RubyString) value).isEmpty();
      case ClassIndex.ARRAY:
        return !((RubyArray) value).isEmpty();
      case ClassIndex.HASH:
        return !((RubyHash) value).isEmpty();
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
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    if (nativeTypeIndex == ClassIndex.HASH) {
      IRubyObject result = ((RubyHash) value).fastARef(name);
      return result == null ? ruby.getNil() : result;
    } else {
      return ruby.getNil();
    }
  }

  @Override
  @SuppressWarnings("unchecked")
  public Collection<IRubyObject> getPropertyNames(IRubyObject value) {
    int nativeTypeIndex = ((RubyObject) value).getNativeTypeIndex();
    if (nativeTypeIndex == ClassIndex.HASH) {
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

  @Override
  public int compare(IRubyObject value1, IRubyObject value2) {
    JmesPathType type1 = typeOf(value1);
    JmesPathType type2 = typeOf(value2);
    if (type1 == type2) {
      switch (type1) {
        case NULL:
          return 0;
        case BOOLEAN:
          return value1.isTrue() == value2.isTrue() ? 0 : -1;
        case NUMBER:
        case STRING:
        case ARRAY:
          RubyObject o1 = (RubyObject) value1;
          RubyObject o2 = (RubyObject) value2;
          return o1.compareTo(o2);
        case OBJECT:
          return value1.op_equal(ruby.getCurrentContext(), value2).isTrue() ? 0 : -1;
        default:
          throw new IllegalStateException(String.format("Unknown node type encountered: %s", value1.getClass().getName()));
      }
    } else {
      return -1;
    }
  }
}
