(function() {
  var Binding, el,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  el = this.elvis;

  /*
    Class: Binding
  
    Description:
      Sub-class of `elvis.Element`. Handles data bindings using Backbone.Model.
      Supports multi-attribute one- and two-way bindings. An instance of
      `Binding` is returned by calling `model.bindTo`.
  */


  Binding = (function(_super) {
    __extends(Binding, _super);

    function Binding(model, attributes) {
      this.model = model;
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

    Binding.prototype.getValue = function() {
      var attr, transform, values;
      values = (function() {
        var _i, _len, _ref, _results;
        _ref = this.attrs;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          _results.push(this.model.get(attr));
        }
        return _results;
      }).call(this);
      transform = this._getTransform;
      if (transform) {
        return transform.apply(null, values);
      } else {
        return values.join(' ');
      }
    };

    Binding.prototype.setAttr = function(obj, attribute) {
      var attr, _i, _len, _ref,
        _this = this;
      this.toObj = obj;
      this.toAttr = attribute;
      if (obj.tagName === 'INPUT' && attribute === 'value') {
        el.on(obj, 'change', function() {
          return _this.updateModel(obj[attribute]);
        });
      }
      _ref = this.attrs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        this.model.on("change:" + attr, this.update, this);
      }
      return this.update();
    };

    Binding.prototype.update = function() {
      return el.setAttr(this.toObj, this.toAttr, this.getValue());
    };

    Binding.prototype.updateModel = function(value) {
      if (this.attrs.length > 1) {
        return this.model.set(this._setTransform(value));
      } else {
        return this.model.set(this.attrs[0], value);
      }
    };

    return Binding;

  })(el.Element);

  Backbone.Model.prototype.bindTo = function(attributes) {
    return new Binding(this, attributes);
  };

}).call(this);
