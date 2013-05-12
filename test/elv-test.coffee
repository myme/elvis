{assert, refute} = buster

el = @el


buster.testCase 'el',

  'can create':

    'div by default': ->
      assert.match(el().tagName, 'div')

    'an input field': ->
      assert.match(el('input').tagName, 'input')

    'a span': ->
      assert.match(el('span').tagName, 'span')

    'div with class': ->
      assert.match el('.class'),
        tagName: 'div'
        className: 'class'

    'div with multiple classes': ->
      assert.match el('.class1.class2'),
        tagName: 'div'
        className: 'class1 class2'

    'div with id': ->
      assert.match el('#some-element'),
        tagName: 'div'
        id: 'some-element'

    'div with id and classes': ->
      assert.match el('.class1#some-element.class2'),
        tagName: 'div'
        id: 'some-element'
        className: 'class1 class2'

    'span with class': ->
      assert.match el('span.class'),
        tagName: 'span'
        className: 'class'

  'can append':

    'element text as second argument': ->
      element = el('div', 'foo bar')
      assert.tagName(element, 'div')
      assert.equals(element.innerHTML, 'foo bar')

    'element text as array of text': ->
      element = el('div', [ 'foo', ' ', 'bar' ])
      assert.tagName(element, 'div')
      assert.equals(element.innerHTML, 'foo bar')

    'element child': ->
      element = el('div', el('em', 'foo'))
      assert.equals(element.innerHTML, '<em>foo</em>')

    'array of children': ->
      element = el('div', [
        el('em', 'foo')
        ' bar'
      ])
      assert.equals(element.innerHTML, '<em>foo</em> bar')

  'doest not call .setAttr with no id or classes': ->
    stub = @stub(el, 'setAttr')
    el()
    refute.called(stub)

  'calls .setAttr for setting id': ->
    stub = @stub(el, 'setAttr')
    element = el('#some-id')
    assert.calledOnceWith(stub, element, 'id', 'some-id')

  'calls .setAttr for setting className': ->
    stub = @stub(el, 'setAttr')
    element = el('.class1.class2')
    assert.calledOnceWith(stub, element, 'className', 'class1 class2')


buster.testCase 'el.setAttr',

  'can set element id': ->
    element = el()
    el.setAttr(element, 'id', 'some-id')
    assert.equals(element.id, 'some-id')

  'can set element className': ->
    element = el()
    el.setAttr(element, 'className', 'class1 class2')
    assert.equals(element.className, 'class1 class2')

  'can set element innerHTML with html': ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    assert.equals(element.innerHTML, '<em>foo</em> bar')

  'can set / get element text content': ->
    element = el()
    el.setAttr(element, 'text', '<em>foo</em> bar')
    assert.equals(element.innerHTML, '&lt;em&gt;foo&lt;/em&gt; bar')


buster.testCase 'el.getAttr',

  'can get element id': ->
    assert.equals(el.getAttr(el('#some-id'), 'id'), 'some-id')

  'can get element className': ->
    assert.equals(el.getAttr(el('.class1.class2'), 'className'), 'class1 class2')

  'can get element innerHTML with html': ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    assert.equals(el.getAttr(element, 'html'), '<em>foo</em> bar')

  'can get element text content with text': ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    assert.equals(el.getAttr(element, 'text'), 'foo bar')
