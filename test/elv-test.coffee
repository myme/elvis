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

    'does not add id attribute by default': ->
      refute(el().hasAttribute('id'))

    'does not add className attribute by default': ->
      refute(el().hasAttribute('className'))

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

    'anchor with href': ->
      assert.match el('a(href="/foo/bar")', 'baz'),
        tagName: 'a'
        href: '/foo/bar'
        innerHTML: 'baz'

    'input with name and type': ->
      assert.match el('input(name="verify",type="password")'),
        tagName: 'input'
        name: 'verify'
        type: 'password'

    'anchor with id, classes, attribute value and inner text': ->
      assert.match el('input#verify-password.class1.class2(name="verify",type="password")', 'baz'),
        tagName: 'input'
        id: 'verify-password'
        className: 'class1 class2'
        name: 'verify'
        type: 'password'

  'can set':

    'tag with attributes': ->
      assert.match el('a', href: '/foo/bar'),
        tagName: 'a'
        href: '/foo/bar'

    'tag with id set through attributes': ->
      assert.match el('div#foo', id: 'bar'),
        tagName: 'div'
        id: 'bar'

    'tag with className set through attributes': ->
      assert.match el('div.foo', className: 'bar'),
        tagName: 'div'
        className: 'bar'

    'tag with tag attributes overridden': ->
      assert.match el('a(href="/foo/bar")', href: '/baz/quux'),
        tagName: 'a'
        href: '/baz/quux'

    'tag with attributes and children': ->
      assert.match el('a', { href: '/foo/bar' }, [ 'foo', ' ', 'bar' ]),
        tagName: 'a'
        href: '/foo/bar'
        innerHTML: 'foo bar'

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

  'can modify element':

    'setting text content': ->
      element = el('div', 'foo')
      el(element, 'bar')
      assert.equals(element.innerHTML, 'bar')

    'setting HTML content': ->
      element = el('div', 'foo')
      el(element, el('em', 'foo'))
      assert.equals(element.innerHTML, '<em>foo</em>')

    'setting array of HTML content': ->
      element = el('div', 'foo')
      el(element, [
        el('em', 'foo')
        ' bar'
      ])
      assert.equals(element.innerHTML, '<em>foo</em> bar')


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

  'can set HTML content from DOM element': ->
    element = el()
    el.setAttr(element, 'html', el('em', 'foo'))
    assert.equals(element.innerHTML, '<em>foo</em>')

  'can set multiple attributes': ->
    element = el()
    el.setAttr(element, id: 'some-id', className: 'class')
    assert.match element,
      id: 'some-id'
      className: 'class'

  'can set href on anchor': ->
    element = el('a')
    el.setAttr(element, href: '/foo/bar')
    assert.match(element, href: '/foo/bar')


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


buster.testCase 'el.registerPlugin',

  'can register plugin called on appended elements': ->
    el.registerPlugin(spy = @spy())
    el('div', [ 'foo', 'bar' ])
    assert.calledTwice(spy)
    assert.calledWith(spy, 'foo')
    assert.calledWith(spy, 'bar')

  'can register plugin replacing elements': ->
    children = [
      el('span', 'baz')
      el('span', 'quux')
    ]
    el.registerPlugin((child) -> children.shift())
    assert.match el('div', [ 'foo', 'bar' ]),
      innerHTML: '<span>baz</span><span>quux</span>'


buster.testCase 'el.resetPlugins',

  'removes registered plugins': ->
    el.registerPlugin(spy = @spy())
    el.resetPlugins()
    el('div', [ 'foo', 'bar' ])
    refute.called(spy)
