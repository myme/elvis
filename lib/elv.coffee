doc = @document


isElement = (el) ->
  el.nodeType and el.nodeType is doc.ELEMENT_NODE


isText = (el) ->
  el.nodeType and el.nodeType is doc.TEXT_NODE


normalizeArguments = (args) ->
  attributes = {}
  children = []
  length = args and args.length

  if length is 2
    attributes = args[0]
    children = args[1]
  else if length is 1
    if typeof args[0] is 'string' or isElement(args[0])
      children = [ args[0] ]
    else if args[0] instanceof Array
      children = args[0]

  [attributes, children]


parseTagSpec = (tagSpec) ->
  tag = 'div'
  id = null
  classes = []

  if tagSpec
    for match in tagSpec.match(/[.#]?(\w|-)+/g)
      switch match.substr(0, 1)
        when '#'
          id = match.substr(1)
        when '.'
          classes.push(match.substr(1))
        else
          tag = match

  [tag, id, classes]


textNode = (text) ->
  doc.createTextNode(text)


@el = element = (tagSpec, args...) ->
  [attributes, children] = normalizeArguments(args)
  [tag, id, classes] = parseTagSpec(tagSpec)

  el = doc.createElement(tag)
  element.setAttr(el, 'id', id) if id
  element.setAttr(el, 'className', classes.join(' ')) if classes.length

  element.appendChildren(el, children)

  el


directAttributes =
  'className': 'className'
  'id': 'id'
  'html': 'innerHTML'
  'text': 'textContent'


@el.appendChildren = (el, children) ->
  if children.length
    fragment = doc.createDocumentFragment()
    for child in children
      if typeof child is 'string'
        child = textNode(child)
      fragment.appendChild(child)
    el.appendChild(fragment)


@el.getAttr = (el, attr) ->
  directAttr = directAttributes[attr]
  if directAttr
    el[directAttr]


@el.setAttr = (el, attr, value) ->
  directAttr = directAttributes[attr]
  if directAttr
    el[directAttr] = value
