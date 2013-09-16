(function() {
  var Binding, el,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  el = this.elvis;

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

    Binding.prototype.fromModel = function(transform) {
      this._fromModelTransform = transform;
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
      transform = this._fromModelTransform;
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

    Binding.prototype.toModel = function(transform) {
      this._toModelTransform = transform;
      return this;
    };

    Binding.prototype.update = function() {
      return el.setAttr(this.toObj, this.toAttr, this.getValue());
    };

    Binding.prototype.updateModel = function(value) {
      var attr, idx, transform, _i, _len, _ref, _results;
      value = (transform = this._toModelTransform) ? transform(value) : value;
      if (!(value instanceof Array)) {
        value = [value];
      }
      _ref = this.attrs;
      _results = [];
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        attr = _ref[idx];
        _results.push(this.model.set(attr, value[idx]));
      }
      return _results;
    };

    return Binding;

  })(el.Element);

  Backbone.Model.prototype.bindTo = function(attributes) {
    return new Binding(this, attributes);
  };

}).call(this);
