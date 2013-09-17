(function() {
  var booleanAttributes, canAppend, directAttributes, doc, exports, isElement, isText, merge, normalizeArguments, parseAttrString, parseTagSpec, textNode,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  doc = this.document;

  isElement = function(el) {
    return (el != null ? el.nodeType : void 0) && el.nodeType === doc.ELEMENT_NODE;
  };

  isText = function(el) {
    return (el != null ? el.nodeType : void 0) && el.nodeType === doc.TEXT_NODE;
  };

  merge = function(left, right) {
    var attr, dest, value;
    dest = {};
    for (attr in left) {
      if (!__hasProp.call(left, attr)) continue;
      value = left[attr];
      dest[attr] = value;
    }
    for (attr in right) {
      if (!__hasProp.call(right, attr)) continue;
      value = right[attr];
      dest[attr] = value;
    }
    return dest;
  };

  canAppend = function(el) {
    return typeof el === 'string' || isElement(el) || isText(el) || el instanceof exports.Element;
  };

  normalizeArguments = function(args) {
    var attributes, children, length;
    attributes = {};
    children = [];
    length = args && args.length;
    if (length === 2) {
      attributes = args[0];
      children = args[1];
      if (!(children instanceof Array)) {
        children = [children];
      }
    } else if (length === 1) {
      if (canAppend(args[0])) {
        children = [args[0]];
      } else if (args[0] instanceof Array) {
        children = args[0];
      } else if (typeof args[0] === 'object') {
        attributes = args[0];
      }
    }
    return [attributes, children];
  };

  parseAttrString = function(attrStr) {
    var attributes, key, pair, value, _i, _len, _ref, _ref1;
    attributes = {};
    _ref = attrStr.split(',');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      pair = _ref[_i];
      _ref1 = pair.split('='), key = _ref1[0], value = _ref1[1];
      attributes[key] = value.replace(/^"(.*)"$/, '$1');
    }
    return attributes;
  };

  parseTagSpec = function(tagSpec) {
    var attributes, classes, match, tag, tagAttrs, _i, _len, _ref;
    tag = 'div';
    attributes = {};
    classes = [];
    if (tagSpec) {
      _ref = tagSpec.match(/\([^)]+\)|[.#]?(\w|-)+/g);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        match = _ref[_i];
        switch (match.substr(0, 1)) {
          case '#':
            attributes.id = match.substr(1);
            break;
          case '.':
            classes.push(match.substr(1));
            break;
          case '(':
            tagAttrs = parseAttrString(match.substr(1, match.length - 2));
            attributes = merge(attributes, tagAttrs);
            break;
          default:
            tag = match;
        }
      }
      if (classes.length) {
        attributes.className = classes.join(' ');
      }
    }
    return [tag, attributes];
  };

  /*
    Function: elvis
  
    Examples:
      elvis('div', 'This is a div with some text.');
  
      elvis('div#div-id.class1.class2', [
        elvis('span', 'This is a child element.')
      ]);
  
    Description:
      Main element creation function.
  */


  this.elvis = exports = function() {
    var args, attributes, children, el, tag, tagAttrs, tagSpecOrEl, _ref, _ref1;
    tagSpecOrEl = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    _ref = normalizeArguments(args), attributes = _ref[0], children = _ref[1];
    if (isElement(tagSpecOrEl)) {
      el = tagSpecOrEl;
    } else {
      _ref1 = parseTagSpec(tagSpecOrEl), tag = _ref1[0], tagAttrs = _ref1[1];
      attributes = merge(tagAttrs, attributes);
      el = doc.createElement(tag);
    }
    if (children.length) {
      attributes.html = children;
    }
    exports.setAttr(el, attributes);
    return el;
  };

  /*
    Class: elvis.Element
  
    Description:
      Base class intended to be overridden by plugins. The `elvis.Element` class
      can be used as a base class for plugins which wish to perform special
      behavior when elements are added to the DOM or set as element attributes.
  */


  exports.Element = (function() {
    function Element(value) {
      this.value = value;
    }

    Element.prototype.getElement = function() {
      return textNode(this.value);
    };

    Element.prototype.setAttr = function(obj, attr) {
      return exports.setAttr(obj, attr, this.value);
    };

    return Element;

  })();

  exports.on = function(element, event, callback) {
    return element.addEventListener(event, callback);
  };

  /*
    Function: elvis.text
  
    Description:
      Create a plain text node.
  */


  exports.text = textNode = function(text) {
    return doc.createTextNode(text);
  };

  directAttributes = {
    'className': 'className',
    'id': 'id',
    'html': 'innerHTML',
    'text': 'textContent',
    'value': 'value'
  };

  booleanAttributes = {
    'checked': true,
    'selected': true,
    'disabled': true,
    'readonly': true,
    'multiple': true,
    'ismap': true,
    'defer': true,
    'declare': true,
    'noresize': true,
    'nowrap': true,
    'noshade': true,
    'compact': true
  };

  /*
    Function: elvis.appendChildren
  
    Description:
      Appends child elements to an HTML element.
  */


  exports.appendChildren = function(el, children) {
    var child, fragment, _i, _len;
    if (children.length) {
      fragment = doc.createDocumentFragment();
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        child = children[_i];
        if (!(child)) {
          continue;
        }
        if (child instanceof Array) {
          exports.appendChildren(fragment, child);
          continue;
        }
        if (typeof child === 'string') {
          child = new exports.Element(child);
        }
        if (child instanceof exports.Element) {
          child = child.getElement();
        }
        fragment.appendChild(child);
      }
      return el.appendChild(fragment);
    }
  };

  /*
    Function: elvis.css
  
    Description:
      Generates `element.style`-compatible CSS strings.
  */


  exports.css = function(styles) {
    var css, key, output, value;
    output = [];
    for (key in styles) {
      if (!__hasProp.call(styles, key)) continue;
      value = styles[key];
      if (typeof value === 'string') {
        output.push("" + key + ":" + value + ";");
      } else {
        css = exports.css(value);
        output.push("" + key + "{" + css + "}");
      }
    }
    return output.join('');
  };

  exports.getAttr = function(el, attr) {
    var directAttr;
    directAttr = directAttributes[attr];
    if (directAttr) {
      return el[directAttr];
    }
  };

  /*
    Function: elvis.setAttr
  
    Examples:
      elvis.setAttr(el, html: 'This is html content');
  
      elvis.setAttr(el, {
        href: 'http://example.com',
        html: 'This is html content'
      });
  
    Description:
      Sets element attributes in a consistent way.
  */


  exports.setAttr = function() {
    var args, attr, directAttr, el, value, _ref, _results;
    el = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (args.length === 1) {
      _ref = args[0];
      _results = [];
      for (attr in _ref) {
        if (!__hasProp.call(_ref, attr)) continue;
        value = _ref[attr];
        _results.push(exports.setAttr(el, attr, value));
      }
      return _results;
    } else {
      attr = args[0], value = args[1];
      if (value instanceof exports.Element) {
        return value.setAttr(el, attr);
      } else {
        directAttr = directAttributes[attr];
        if (booleanAttributes[attr]) {
          if (value) {
            return el[attr] = true;
          } else {
            return el.removeAttribute(attr);
          }
        } else if (!directAttr) {
          return el.setAttribute(attr, value);
        } else {
          if (attr === 'html' && typeof value !== 'string') {
            el.innerHTML = '';
            if (isElement(value)) {
              return el.appendChild(value);
            } else if (value instanceof Array) {
              return exports.appendChildren(el, value);
            }
          } else {
            return el[directAttr] = value;
          }
        }
      }
    }
  };

}).call(this);
