doc = @document


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


@el = element = (tagSpec) ->
  [tag, id, classes] = parseTagSpec(tagSpec)
  el = doc.createElement(tag)
  element.setAttr(el, 'id', id) if id
  element.setAttr(el, 'className', classes.join(' ')) if classes.length
  el


directAttributes =
  'className': 'className'
  'id': 'id'
  'html': 'innerHTML'
  'text': 'textContent'


@el.getAttr = (el, attr) ->
  directAttr = directAttributes[attr]
  if directAttr
    el[directAttr]


@el.setAttr = (el, attr, value) ->
  directAttr = directAttributes[attr]
  if directAttr
    el[directAttr] = value
