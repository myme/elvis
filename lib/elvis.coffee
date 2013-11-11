doc = @document


ELEMENT_NODE = 1
TEXT_NODE = 3


isElement = (el) ->
  el?.nodeType and el.nodeType is ELEMENT_NODE


isText = (el) ->
  el?.nodeType and el.nodeType is TEXT_NODE


merge = (left, right) ->
  dest = {}
  dest[attr] = value for own attr, value of left
  dest[attr] = value for own attr, value of right
  dest


canAppend = (el) ->
  (
    typeof el is 'string' or
    isElement(el) or
    isText(el) or
    el instanceof exports.Element
  )


normalizeArguments = (args) ->
  attributes = {}
  children = []
  length = args and args.length

  if length is 2
    attributes = args[0]
    children = args[1]
    if children not instanceof Array
      children = [ children ]
  else if length is 1
    if canAppend(args[0])
      children = [ args[0] ]
    else if args[0] instanceof Array
      children = args[0]
    else if typeof args[0] is 'object'
      attributes = args[0]

  [ attributes, children ]


parseAttrString = (attrStr) ->
  attributes = {}

  for pair in attrStr.split(',')
    [key, value] = pair.split('=')
    attributes[key] = value.replace(/^"(.*)"$/, '$1')

  attributes


parseTagSpec = (tagSpec) ->
  tag = 'div'
  attributes = {}
  classes = []

  if tagSpec
    for match in tagSpec.match /\([^)]+\)|[.#]?(\w|-)+/g
      switch match.substr(0, 1)
        when '#'
          attributes.id = match.substr(1)
        when '.'
          classes.push(match.substr(1))
        when '('
          tagAttrs = parseAttrString(match.substr(1, match.length - 2))
          attributes = merge(attributes, tagAttrs)
        else
          tag = match
    attributes.className = classes.join(' ') if classes.length

  [tag, attributes]


###
  Function: elvis

  Examples:
    elvis('div', 'This is a div with some text.');

    elvis('div#div-id.class1.class2', [
      elvis('span', 'This is a child element.')
    ]);

  Description:
    Main element creation function.
###
@elvis = exports = (tagSpecOrEl, args...) ->
  [attributes, children] = normalizeArguments(args)

  if isElement(tagSpecOrEl)
    el = tagSpecOrEl
  else
    [tag, tagAttrs] = parseTagSpec(tagSpecOrEl)
    attributes = merge(tagAttrs, attributes)
    el = doc.createElement(tag)

  attributes.html = children if children.length
  exports.setAttr(el, attributes)

  el


###
  Class: elvis.Element

  Description:
    Base class intended to be overridden by plugins. The `elvis.Element` class
    can be used as a base class for plugins which wish to perform special
    behavior when elements are added to the DOM or set as element attributes.
###
class exports.Element
  constructor: (@value) ->
  getElement: -> textNode(@value)
  setAttr: (obj, attr) ->
    exports.setAttr(obj, attr, @value)


exports.on = (element, event, callback) ->
  element.addEventListener(event, callback)


###
  Function: elvis.text

  Description:
    Create a plain text node.
###
exports.text = textNode = (text) ->
  doc.createTextNode(text)


# Some browsers support `innerText` while others use `textContent`
textAttr = do ->
  element = doc.createElement('div')
  if 'textContent' of element then 'textContent' else 'innerText'


directAttributes =
  'className': 'className'
  'id': 'id'
  'html': 'innerHTML'
  'text': textAttr
  'value': 'value'


booleanAttributes =
  'checked': true
  'selected': true
  'disabled': true
  'readonly': true
  'multiple': true
  'ismap': true
  'defer': true
  'declare': true
  'noresize': true
  'nowrap': true
  'noshade': true
  'compact': true


###
  Function: elvis.appendChildren

  Description:
    Appends child elements to an HTML element.
###
exports.appendChildren = (el, children) ->
  if children.length
    fragment = doc.createDocumentFragment()
    for child in children when child
      if child instanceof Array
        exports.appendChildren(fragment, child)
        continue
      if typeof child is 'string'
        child = new exports.Element(child)
      if child instanceof exports.Element
        child = child.getElement()
      fragment.appendChild(child)
    el.appendChild(fragment)


###
  Function: elvis.css

  Description:
    Generates `element.style`-compatible CSS strings.
###
exports.css = (styles) ->
  output = []
  for own key of styles
    value = styles[key]
    if typeof value is 'string'
      output.push("#{key}:#{value};")
    else
      css = exports.css(value)
      output.push("#{key}{#{css}}")
  output.join('')


exports.getAttr = (el, attr) ->
  directAttr = directAttributes[attr]
  if directAttr
    el[directAttr]


###
  Function: elvis.setAttr

  Examples:
    elvis.setAttr(el, html: 'This is html content');

    elvis.setAttr(el, {
      href: 'http://example.com',
      html: 'This is html content'
    });

  Description:
    Sets element attributes in a consistent way.
###
exports.setAttr = (el, args...) ->
  if args.length is 1
    for own attr, value of args[0]
      exports.setAttr(el, attr, value)
  else
    [attr, value] = args
    if value instanceof exports.Element
      value.setAttr(el, attr)
    else
      directAttr = directAttributes[attr]
      if booleanAttributes[attr]
        if value
          el[attr] = true
        else
          el.removeAttribute(attr)
      else if not directAttr
        el.setAttribute(attr, value)
      else
        if attr is 'html' and typeof value isnt 'string'
          el.removeChild(el.lastChild) while el.lastChild
          if isElement(value)
            el.appendChild(value)
          else if value instanceof Array
            exports.appendChildren(el, value)
        else if attr is 'text' and isText(el)
          el.nodeValue = value
        else
          el[directAttr] = value
  null


class SafeString extends exports.Element
  toString: -> @value
  getElement: ->
    nodes = exports('div', html: @value).childNodes
    fragment = doc.createDocumentFragment()
    fragment.appendChild(nodes[0]) while nodes.length
    fragment


###
  Function: elvis.safe

  Examples:
    elvis('div', elvis.safe('<span>foobar</span>'));

  Description:
    Marks a string value as "safe" which means that it will not be escaped when
    injected into the DOM.
###
exports.safe = (args...) ->
  new SafeString(args...)


oldSafe = null


###
  Function: elvis.infectString

  Examples:
    elvis.infectString();
    elvis('div', '<span>foobar</span>'.safe());

  Description:
    Add a function with name 'safe' to the String prototype, in order to
    simplify marking strings as safe, e.g. they will not be escaped.
###
exports.infectString = ->
  oldSafe = String::safe
  String::safe = -> exports.safe(@toString())


###
  Function: elvis.restoreString

  Examples:
    elvis.infectString()
    elvis.restoreString()

  Description:
    Restore the String prototype, removing injected functions.
###
exports.restoreString = ->
  if oldSafe
    String::safe = oldSafe
  else
    delete String::safe
  oldSafe = null
