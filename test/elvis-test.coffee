el = @elvis
{assert, refute} = buster


createEvent = (type) ->
  event = document.createEvent('HTMLEvents')
  event.initEvent(type, true, false)
  event


buster.testCase 'elvis',
  'can create':
    'div by default': ->
      assert.match(el(), tagName: 'div')

    'an input field': ->
      assert.match(el('input'), tagName: 'input')

    'a span': ->
      assert.match(el('span'), tagName: 'span')

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
        href: new RegExp('/foo/bar')
        innerHTML: 'baz'

    'input with name and type': ->
      assert.match el('input(name="verify",type="password")'),
        tagName: 'input'
        name: 'verify'
        type: 'password'

    'anchor with id, classes, attribute value and inner text': ->
      tagSpec = '''
        input#verify-password.class1.class2(name="verify",type="password")
      '''
      assert.match el(tagSpec, 'baz'),
        tagName: 'input'
        id: 'verify-password'
        className: 'class1 class2'
        name: 'verify'
        type: 'password'

  'can set tag with attributes': ->
    assert.match el('a', href: '/foo/bar'),
      tagName: 'a'
      href: new RegExp('/foo/bar')

  'does not add id attribute by default': ->
    refute(el().hasAttribute('id'))

  'does not add className attribute by default': ->
    refute(el().hasAttribute('className'))

  'can set':
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
        href: new RegExp('/baz/quux')

    'tag with attributes and inner text': ->
      assert.match el('a', { href: '/foo/bar' }, 'foo'),
        tagName: 'a'
        href: new RegExp('/foo/bar')
        innerHTML: 'foo'

    'tag with attributes and single child element': ->
      child = el('span', 'foo')
      assert.match el('a', { href: '/foo/bar' }, child),
        tagName: 'a'
        href: new RegExp('/foo/bar')
        innerHTML: '<span>foo</span>'

    'tag with attributes and children': ->
      assert.match el('a', { href: '/foo/bar' }, [ 'foo', ' ', 'bar' ]),
        tagName: 'a'
        href: new RegExp('/foo/bar')
        innerHTML: 'foo bar'

  'can append':
    'element text as second argument': ->
      assert.match el('div', 'foo bar'),
        tagName: 'div'
        innerHTML: 'foo bar'

    'undefined as second argument': ->
      assert.match el('div', undefined),
        tagName: 'div'
        innerHTML: ''

    'element text as array of text': ->
      assert.match el('div', [ 'foo', ' ', 'bar' ]),
        tagName: 'div'
        innerHTML: 'foo bar'

    'element child': ->
      assert.match el('div', el('em', 'foo')),
        innerHTML: '<em>foo</em>'

    'array of children': ->
      assert.match el('div', [
        el('em', 'foo')
        ' bar'
      ]), innerHTML: '<em>foo</em> bar'

    'handles HTML text sanely': ->
      assert.match el('div', '<span>foo</span>'),
        innerHTML: '&lt;span&gt;foo&lt;/span&gt;'

  'ignores null': ->
    assert.match el('div', null),
      tagName: 'div'
      innerHTML: ''

  'ignores null in array': ->
    assert.match el('div', [ 'foo', null, 'bar' ]),
      tagName: 'div'
      innerHTML: 'foobar'

  'can set element properties': ->
    assert.match el('div', el('button', disabled: false)),
      innerHTML: '<button></button>'

    html = el('div', el('button', disabled: true)).innerHTML
    assert(
      html is '<button disabled></button>' or
      html is '<button disabled=""></button>' or
      html is '<button disabled="disabled"></button>'
    )

  'can modify element setting text content': ->
    element = el('div', 'foo')
    el(element, 'bar')
    assert.match(element, innerHTML: 'bar')

  'can modify setting HTML content': ->
    element = el('div', 'foo')
    el(element, el('em', 'foo'))
    assert.match(element, innerHTML: '<em>foo</em>')

  'can modify setting array of HTML content': ->
    element = el('div', 'foo')
    el(element, [
      el('em', 'foo')
      ' bar'
    ])
    assert.match(element, innerHTML: '<em>foo</em> bar')

  'append children':
    'can append strings': ->
      assert.match(el('div', 'foo'), innerHTML: 'foo')

    'can append DOM elements': ->
      assert.match el('div', el('span', 'foo')),
        innerHTML: '<span>foo</span>'

    'can append text nodes': ->
      assert.match(el('div', el.text('foo')), innerHTML: 'foo')

    'can append Element instances': ->
      assert.match(el('div', new el.Element('foo')), innerHTML: 'foo')

    'flattens out nested arrays': ->
      html = el('div', [
        el('span', 'foo')
        [
          []  # empty no-op array
          el('span', 'bar')
          [
            el('span', 'baz')
          ]
        ]
      ]).innerHTML
      assert.equals(html, '<span>foo</span><span>bar</span><span>baz</span>')

    'can use conditionals in array': ->
      html = el('div', [
        el('span', 'foo')
        if true then [
          el('span', 'this is true')
        ]
        if false then [
          el('span', 'this is false')
        ]
      ]).innerHTML
      assert.equals(html, '<span>foo</span><span>this is true</span>')


buster.testCase 'elvis.css',
  'can create basic css properties': ->
    css = el.css(color: '#00f')
    assert.equals(css, 'color:#00f;')

  'can create multiple properties': ->
    css = el.css(color: '#00f', padding: '10px')
    assert.equals(css, 'color:#00f;padding:10px;')

  'can receive selectors': ->
    css = el.css(body: padding: '10px')
    assert.equals(css, 'body{padding:10px;}')


buster.testCase 'elvis.setAttr',
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
    assert.match(element.innerHTML, '&lt;em&gt;foo&lt;/em&gt; bar')

  'can set HTML content from DOM element': ->
    element = el()
    el.setAttr(element, 'html', el('em', 'foo'))
    assert.match(element.innerHTML, '<em>foo</em>')

  'can set multiple attributes': ->
    element = el()
    el.setAttr(element, id: 'some-id', className: 'class')
    assert.match(element, id: 'some-id', className: 'class')

  'can set href on anchor': ->
    element = el('a')
    el.setAttr(element, href: '/foo/bar')
    assert.match(element.href, new RegExp('/foo/bar'))

  'can set className value from Element': ->
    element = el('span')
    el.setAttr(element, className: new el.Element('foo'))
    assert.match(element.className, 'foo')

  'can set href value from Element': ->
    element = el('a')
    el.setAttr(element, href: new el.Element('/foo/bar'))
    assert.match(element.href, new RegExp('/foo/bar'))

  'can set disabled': ->
    element = el('button')

    el.setAttr(element, disabled: true)
    assert(element.disabled)

    el.setAttr(element, disabled: false)
    refute(element.disabled)


buster.testCase 'elvis.getAttr',
  'can get element id': ->
    assert.equals(el.getAttr(el('#some-id'), 'id'), 'some-id')

  'can get element className': ->
    assert.equals(
      el.getAttr(el('.class1.class2'), 'className'),
      'class1 class2')

  'can get element innerHTML with html': ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    assert.equals(el.getAttr(element, 'html'), '<em>foo</em> bar')

  'can get element text content with text': ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    assert.equals(el.getAttr(element, 'text'), 'foo bar')


buster.testCase 'elvis.on',
  'can add event listeners': ->
    element = el('input')
    spy = sinon.spy()
    el.on(element, 'change', spy)
    element.dispatchEvent(createEvent('change'))
    assert.calledOnce(spy)


buster.testCase 'elvis.text',
  'can create a text node': ->
    node = el.text('foo')
    assert.match node,
      nodeType: document.TEXT_NODE
      textContent: 'foo'

  'can be appended to regularly with el': ->
    element = el('div', el.text('foo'))
    assert.equals(element.innerHTML, 'foo')


buster.testCase '.safe',
  'is a function': ->
    assert.isFunction(el.safe)

  'returns an el.Element instance': ->
    assert(el.safe('foobar') instanceof el.Element)

  'returns an object with a proper .toString': ->
    assert.equals(el.safe('foobar') + '', 'foobar')

  'can be inject HTML into an elvis element': ->
    html = el('div', el.safe('foo<span>bar</span>baz')).innerHTML
    assert.equals(html, 'foo<span>bar</span>baz')

  'can insert HTML entities into an elvis element': ->
    html = el('div', el.safe('foo &mdash; bar')).innerHTML
    assert.equals(html, 'foo — bar')


buster.testCase '.infectString',
  'is a function': ->
    assert.isFunction(el.infectString)

  'adds .safe to the String prototype': ->
    el.infectString()
    assert.isFunction('foo'.safe)
    el.restoreString()

  '"".safe returns an el.Element instance': ->
    el.infectString()
    assert('foo'.safe() instanceof el.Element)
    el.restoreString()

  'can be used to mark strings as safe': ->
    el.infectString()
    html = el('div', 'foo<span>bar</span>baz'.safe()).innerHTML
    assert.equals(html, 'foo<span>bar</span>baz')
    el.restoreString()

  'can create more elaborate markup': ->
    el.infectString()
    html = el('div', [
      'foo &mdash; bar'.safe()
      '<em>bold</em>'.safe()
      el('span', 'blergh')
    ]).innerHTML
    assert.equals(html, 'foo — bar<em>bold</em><span>blergh</span>')
    el.restoreString()


buster.testCase '.restoreString',
  'is a function': ->
    assert.isFunction(el.restoreString)

  'removes .safe from the String prototype, restoring last value': ->
    oldSafe = ->
    String::safe = oldSafe
    el.infectString()
    el.restoreString()
    assert.equals(String::safe, oldSafe)
