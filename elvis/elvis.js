/*
elvis 1.0.2 -- 2015-06-01

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
  var ELEMENT_NODE, SafeString, TEXT_NODE, booleanAttributes, canAppend, directAttributes, doc, elvis, isElement, isNative, isText, merge, normalizeArguments, oldSafe, parseAttrString, parseTagSpec, setStyleAttr, textAttr, textNode,
    hasProp = {}.hasOwnProperty,
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  doc = typeof window !== "undefined" && window !== null ? window.document : void 0;

  if (!doc) {
    doc = require('jsdom').jsdom();
  }

  ELEMENT_NODE = 1;

  TEXT_NODE = 3;

  isElement = function(el) {
    return (el != null ? el.nodeType : void 0) && el.nodeType === ELEMENT_NODE;
  };

  isText = function(el) {
    return (el != null ? el.nodeType : void 0) && el.nodeType === TEXT_NODE;
  };

  merge = function(left, right) {
    var attr, dest, value;
    dest = {};
    for (attr in left) {
      if (!hasProp.call(left, attr)) continue;
      value = left[attr];
      dest[attr] = value;
    }
    for (attr in right) {
      if (!hasProp.call(right, attr)) continue;
      value = right[attr];
      dest[attr] = value;
    }
    return dest;
  };

  isNative = function(el) {
    return typeof el === 'boolean' || typeof el === 'number' || typeof el === 'string';
  };

  canAppend = function(el) {
    return isNative(el) || isElement(el) || isText(el) || el instanceof elvis.Element;
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
    var attributes, i, key, len, pair, ref, ref1, value;
    attributes = {};
    ref = attrStr.split(',');
    for (i = 0, len = ref.length; i < len; i++) {
      pair = ref[i];
      ref1 = pair.split('='), key = ref1[0], value = ref1[1];
      attributes[key] = value.replace(/^"(.*)"$/, '$1');
    }
    return attributes;
  };

  parseTagSpec = function(tagSpec) {
    var attributes, classes, i, len, match, ref, tag, tagAttrs;
    tag = 'div';
    attributes = {};
    classes = [];
    if (tagSpec) {
      ref = tagSpec.match(/\([^)]+\)|[.#]?(\w|-)+/g);
      for (i = 0, len = ref.length; i < len; i++) {
        match = ref[i];
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

  elvis = function() {
    var args, attributes, children, el, ref, ref1, tag, tagAttrs, tagSpecOrEl;
    tagSpecOrEl = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    ref = normalizeArguments(args), attributes = ref[0], children = ref[1];
    if (isElement(tagSpecOrEl)) {
      el = tagSpecOrEl;
    } else {
      ref1 = parseTagSpec(tagSpecOrEl), tag = ref1[0], tagAttrs = ref1[1];
      attributes = merge(tagAttrs, attributes);
      el = doc.createElement(tag);
    }
    if (children.length) {
      attributes.html = children;
    }
    elvis.setAttr(el, attributes);
    return el;
  };


  /*
    Class: elvis.Element
  
    Description:
      Base class intended to be overridden by plugins. The `elvis.Element` class
      can be used as a base class for plugins which wish to perform special
      behavior when elements are added to the DOM or set as element attributes.
   */

  elvis.Element = (function() {
    function Element(value1) {
      this.value = value1;
    }

    Element.prototype.getElement = function() {
      return textNode(this.value);
    };

    Element.prototype.setAttr = function(obj, attr) {
      return elvis.setAttr(obj, attr, this.value);
    };

    return Element;

  })();

  elvis.on = function(element, event, callback) {
    return element.addEventListener(event, callback);
  };


  /*
    Function: elvis.text
  
    Description:
      Create a plain text node.
   */

  elvis.text = textNode = function(text) {
    return doc.createTextNode(text);
  };

  textAttr = (function() {
    var element;
    element = doc.createElement('div');
    if ('textContent' in element) {
      return 'textContent';
    } else {
      return 'innerText';
    }
  })();

  directAttributes = {
    'className': 'className',
    'id': 'id',
    'html': 'innerHTML',
    'text': textAttr,
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

  elvis.appendChildren = function(el, children) {
    var child, fragment, i, len;
    if (children.length) {
      fragment = doc.createDocumentFragment();
      for (i = 0, len = children.length; i < len; i++) {
        child = children[i];
        if (!(child)) {
          continue;
        }
        if (child instanceof Array) {
          elvis.appendChildren(fragment, child);
          continue;
        }
        if (isNative(child)) {
          child = new elvis.Element(child);
        }
        if (child instanceof elvis.Element) {
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

  elvis.css = function(styles) {
    var css, key, output, value;
    output = [];
    for (key in styles) {
      if (!hasProp.call(styles, key)) continue;
      value = styles[key];
      if (typeof value === 'string') {
        output.push(key + ":" + value + ";");
      } else {
        css = elvis.css(value);
        output.push(key + "{" + css + "}");
      }
    }
    return output.join('');
  };

  elvis.getAttr = function(el, attr) {
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

  elvis.setAttr = function() {
    var args, attr, directAttr, el, ref, value;
    el = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    if (args.length === 1) {
      ref = args[0];
      for (attr in ref) {
        if (!hasProp.call(ref, attr)) continue;
        value = ref[attr];
        elvis.setAttr(el, attr, value);
      }
    } else {
      attr = args[0], value = args[1];
      if (value instanceof elvis.Element) {
        value.setAttr(el, attr);
      } else {
        directAttr = directAttributes[attr];
        if (attr === 'style') {
          setStyleAttr(el, value);
        } else if (booleanAttributes[attr]) {
          if (value) {
            el[attr] = true;
          } else {
            el.removeAttribute(attr);
          }
        } else if (!directAttr) {
          el.setAttribute(attr, value);
        } else {
          if (attr === 'html' && typeof value !== 'string') {
            while (el.lastChild) {
              el.removeChild(el.lastChild);
            }
            if (isElement(value)) {
              el.appendChild(value);
            } else if (value instanceof Array) {
              elvis.appendChildren(el, value);
            }
          } else if (attr === 'text' && isText(el)) {
            el.nodeValue = value;
          } else {
            el[directAttr] = value;
          }
        }
      }
    }
    return null;
  };

  setStyleAttr = function(el, styleValue) {
    var key, val;
    if (typeof styleValue === 'string') {
      el.setAttribute('style', styleValue);
    } else {
      for (key in styleValue) {
        if (!hasProp.call(styleValue, key)) continue;
        val = styleValue[key];
        if (val instanceof elvis.Element) {
          val.setAttr(el, 'style', key);
        } else {
          el.style[key] = val;
        }
      }
    }
    return null;
  };

  SafeString = (function(superClass) {
    extend(SafeString, superClass);

    function SafeString() {
      return SafeString.__super__.constructor.apply(this, arguments);
    }

    SafeString.prototype.toString = function() {
      return this.value;
    };

    SafeString.prototype.getElement = function() {
      var fragment, nodes;
      nodes = elvis('div', {
        html: this.value
      }).childNodes;
      fragment = doc.createDocumentFragment();
      while (nodes.length) {
        fragment.appendChild(nodes[0]);
      }
      return fragment;
    };

    return SafeString;

  })(elvis.Element);


  /*
    Function: elvis.safe
  
    Examples:
      elvis('div', elvis.safe('<span>foobar</span>'));
  
    Description:
      Marks a string value as "safe" which means that it will not be escaped when
      injected into the DOM.
   */

  elvis.safe = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(SafeString, args, function(){});
  };

  oldSafe = null;


  /*
    Function: elvis.infectString
  
    Examples:
      elvis.infectString();
      elvis('div', '<span>foobar</span>'.safe());
  
    Description:
      Add a function with name 'safe' to the String prototype, in order to
      simplify marking strings as safe, e.g. they will not be escaped.
   */

  elvis.infectString = function() {
    oldSafe = String.prototype.safe;
    return String.prototype.safe = function() {
      return elvis.safe(this.toString());
    };
  };


  /*
    Function: elvis.restoreString
  
    Examples:
      elvis.infectString()
      elvis.restoreString()
  
    Description:
      Restore the String prototype, removing injected functions.
   */

  elvis.restoreString = function() {
    if (oldSafe) {
      String.prototype.safe = oldSafe;
    } else {
      delete String.prototype.safe;
    }
    return oldSafe = null;
  };

  elvis.document = doc;

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = elvis;
  } else {
    this.elvis = elvis;
  }

}).call(this);
