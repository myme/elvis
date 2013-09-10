(function() {
  var Binding, el,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  el = this.elvis;

  Binding = (function(_super) {
    __extends(Binding, _super);

    function Binding(model, attr, transform) {
      this.model = model;
      this.attr = attr;
      this.transform = transform;
    }

    Binding.prototype.getElement = function() {
      if (!this._element) {
        this._element = el.text();
        this.setAttr(this._element, 'text');
      }
      return this._element;
    };

    Binding.prototype.getValue = function() {
      var value;
      value = this.model.get(this.attr);
      if (this.transform) {
        return this.transform(value);
      } else {
        return value;
      }
    };

    Binding.prototype.setAttr = function(obj, attr) {
      this.toObj = obj;
      this.toAttr = attr;
      this.model.on("change:" + this.attr, this.update, this);
      return this.update();
    };

    Binding.prototype.update = function() {
      return el.setAttr(this.toObj, this.toAttr, this.getValue());
    };

    return Binding;

  })(el.Element);

  el.bind = function(model, attr, transform) {
    return new Binding(model, attr, transform);
  };

}).call(this);
