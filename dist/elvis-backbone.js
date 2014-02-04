(function() {
  var Binding, ModelBinding, ViewBinding, el, virtual, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  el = this.elvis;

  virtual = function(fname) {
    return function() {
      throw new Exception("" + fname + " must be implemented in sub class");
    };
  };

  /*
    Class: Binding
  
    Description:
      Sub-class of `elvis.Element`. Handles data bindings in a generic way.
      Supports multi-attribute one- and two-way bindings.
  */


  Binding = (function(_super) {
    __extends(Binding, _super);

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
        var _i, _len, _ref, _results;
        _ref = this.attrs;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          _results.push(this.getValue(attr));
        }
        return _results;
      }).call(this);
      if (transform = this._getTransform) {
        return transform.call.apply(transform, [this.context].concat(__slice.call(values)));
      } else if (values.length > 1) {
        return values.join(' ');
      } else {
        return values[0];
      }
    };

    Binding.prototype.setAttr = function() {
      var attr, obj, path, _i, _len, _ref,
        _this = this;
      obj = arguments[0], path = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.toObj = obj;
      this.toAttr = path;
      if (obj.tagName === 'INPUT' && path[0] === 'value') {
        el.on(obj, 'change', function() {
          return _this.updateModel(obj.value);
        });
      }
      _ref = this.attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        this.subscribe(attr);
      }
      return this.update();
    };

    Binding.prototype.setValue = virtual('setValue');

    Binding.prototype.subscribe = virtual('subscribe');

    Binding.prototype.update = function() {
      var attr, part, tmp, _i, _len, _ref;
      attr = this._getValue();
      _ref = this.toAttr.slice().reverse();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        part = _ref[_i];
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

  ModelBinding = (function(_super) {
    __extends(ModelBinding, _super);

    function ModelBinding() {
      _ref = ModelBinding.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ModelBinding.prototype.getValue = function() {
      var args, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref1 = this.context).get.apply(_ref1, args);
    };

    ModelBinding.prototype.setValue = function() {
      var args, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref1 = this.context).set.apply(_ref1, args);
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
    })(ModelBinding, [this].concat(__slice.call(arguments)), function(){});
  };

  ViewBinding = (function(_super) {
    __extends(ViewBinding, _super);

    function ViewBinding() {
      _ref1 = ViewBinding.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ViewBinding.prototype.getValue = function() {
      var args, _ref2;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref2 = this.context.model).get.apply(_ref2, args);
    };

    ViewBinding.prototype.setValue = function() {
      var args, _ref2;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref2 = this.context.model).set.apply(_ref2, args);
    };

    ViewBinding.prototype.subscribe = function(attr) {
      var _this = this;
      return this.context.listenTo(this.context.model, "change:" + attr, function() {
        return _this.update();
      });
    };

    return ViewBinding;

  })(Binding);

  Backbone.View.prototype.bindTo = function() {
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(ViewBinding, [this].concat(__slice.call(arguments)), function(){});
  };

}).call(this);
