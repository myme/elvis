/*
elvis 0.3.1 -- 2015-05-28

Copyright (c) 2013-2014, Martin Øinæs Myrseth <myrseth@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.

*/
(function() {
  var Binding, ModelBinding, ViewBinding, el, virtual,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  el = this.elvis;

  virtual = function(fname) {
    return function() {
      throw new Exception(fname + " must be implemented in sub class");
    };
  };


  /*
    Class: Binding
  
    Description:
      Sub-class of `elvis.Element`. Handles data bindings in a generic way.
      Supports multi-attribute one- and two-way bindings.
   */

  Binding = (function(superClass) {
    extend(Binding, superClass);

    function Binding(context, attributes) {
      this.context = context;
      if (!(attributes instanceof Array)) {
        this.attrs = [attributes];
      } else {
        this.attrs = attributes;
      }
    }


    /*
      Function: get
    
      Examples:
        elvis('div', model.bindTo('foo').get(function (foo) {
          return 'The current value of "foo" is ' + foo;
        }));
    
        elvis('div', model.bindTo(['foo', 'bar']).get(function (foo, bar) {
          return 'The current value of "foo" is ' + foo + ', ' +
                 'and "bar" is ' + bar;
        }));
    
      Description:
        Defines a getter transform. The getter transform is passed the current
        values of the bound properties in the order they were defined. The getter
        transform must return a single value to be set on the target object.
     */

    Binding.prototype.get = function(transform) {
      this._getTransform = transform;
      return this;
    };


    /*
      Function: set
    
      Examples:
        elvis('input', {
          value: model.bindTo(['firstName', 'lastName']).set(function (value) {
            var split = value.split(/\s+/);
            return {
              firstName: split[0],
              lastName: split[1],
            };
          })
        });
    
      Description:
        Defines a setter transform for two-way bindings. The setter transform
        must either return a single value if the binding has one attribute, or
        return an object containing the keys to be set on the model if the
        binding is on multiple attributes.
     */

    Binding.prototype.set = function(transform) {
      this._setTransform = transform;
      return this;
    };

    Binding.prototype.getElement = function() {
      if (!this._element) {
        this._element = el.text();
        this.setAttr(this._element, 'text');
      }
      return this._element;
    };

    Binding.prototype.getValue = virtual('getValue');

    Binding.prototype._getValue = function() {
      var attr, transform, values;
      values = (function() {
        var i, len, ref, results;
        ref = this.attrs;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          attr = ref[i];
          results.push(this.getValue(attr));
        }
        return results;
      }).call(this);
      if (transform = this._getTransform) {
        return transform.call.apply(transform, [this.context].concat(slice.call(values)));
      } else if (values.length > 1) {
        return values.join(' ');
      } else {
        return values[0];
      }
    };

    Binding.prototype.setAttr = function() {
      var attr, i, len, obj, path, ref;
      obj = arguments[0], path = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      this.toObj = obj;
      this.toAttr = path;
      if (obj.tagName === 'INPUT' && path[0] === 'value') {
        el.on(obj, 'change', (function(_this) {
          return function() {
            return _this.updateModel(obj.value);
          };
        })(this));
      }
      ref = this.attrs;
      for (i = 0, len = ref.length; i < len; i++) {
        attr = ref[i];
        this.subscribe(attr);
      }
      return this.update();
    };

    Binding.prototype.setValue = virtual('setValue');

    Binding.prototype.subscribe = virtual('subscribe');

    Binding.prototype.update = function() {
      var attr, i, len, part, ref, tmp;
      attr = this._getValue();
      ref = this.toAttr.slice().reverse();
      for (i = 0, len = ref.length; i < len; i++) {
        part = ref[i];
        tmp = {};
        tmp[part] = attr;
        attr = tmp;
      }
      return el.setAttr(this.toObj, attr);
    };

    Binding.prototype.updateModel = function(value) {
      if (this.attrs.length > 1) {
        return this.setValue(this._setTransform(value));
      } else {
        return this.setValue(this.attrs[0], value);
      }
    };

    return Binding;

  })(el.Element);

  ModelBinding = (function(superClass) {
    extend(ModelBinding, superClass);

    function ModelBinding() {
      return ModelBinding.__super__.constructor.apply(this, arguments);
    }

    ModelBinding.prototype.getValue = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return (ref = this.context).get.apply(ref, args);
    };

    ModelBinding.prototype.setValue = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return (ref = this.context).set.apply(ref, args);
    };

    ModelBinding.prototype.subscribe = function(attr) {
      return this.context.on("change:" + attr, this.update, this);
    };

    return ModelBinding;

  })(Binding);

  Backbone.Model.prototype.bindTo = function() {
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(ModelBinding, [this].concat(slice.call(arguments)), function(){});
  };

  ViewBinding = (function(superClass) {
    extend(ViewBinding, superClass);

    function ViewBinding() {
      return ViewBinding.__super__.constructor.apply(this, arguments);
    }

    ViewBinding.prototype.getValue = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return (ref = this.context.model).get.apply(ref, args);
    };

    ViewBinding.prototype.setValue = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return (ref = this.context.model).set.apply(ref, args);
    };

    ViewBinding.prototype.subscribe = function(attr) {
      return this.context.listenTo(this.context.model, "change:" + attr, (function(_this) {
        return function() {
          return _this.update();
        };
      })(this));
    };

    return ViewBinding;

  })(Binding);

  Backbone.View.prototype.bindTo = function() {
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(ViewBinding, [this].concat(slice.call(arguments)), function(){});
  };

}).call(this);
