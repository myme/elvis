el = @elvis

createEvent = (type) ->
  event = document.createEvent('HTMLEvents')
  event.initEvent(type, true, false)
  event

describe 'elvis', ->
  describe 'can create', ->
    it 'div by default', ->
      expect(el().tagName).to.equal('DIV')

    it 'an input field', ->
      expect(el('input').tagName).to.equal('INPUT')

    it 'a span', ->
      expect(el('span').tagName).to.equal('SPAN')

    it 'div with class', ->
      element = el('.class')
      expect(element.tagName).to.equal('DIV')
      expect(element.className).to.equal('class')

    it 'div with multiple classes', ->
      element = el('.class1.class2')
      expect(element.tagName).to.equal('DIV')
      expect(element.className).to.equal('class1 class2')

    it 'div with id', ->
      element = el('#some-element')
      expect(element.tagName).to.equal('DIV')
      expect(element.id).to.equal('some-element')

    it 'div with id and classes', ->
      element = el('.class1#some-element.class2')
      expect(element.tagName).to.equal('DIV')
      expect(element.id).to.equal('some-element')
      expect(element.className).to.equal('class1 class2')

    it 'span with class', ->
      element = el('span.class')
      expect(element.tagName).to.equal('SPAN')
      expect(element.className).to.equal('class')

    it 'anchor with href', ->
      element = el('a(href="/foo/bar")', 'baz')
      expect(element.tagName).to.equal('A')
      expect(element.href).to.match(new RegExp('/foo/bar'))
      expect(element.innerHTML).to.equal('baz')

    it 'input with name and type', ->
      element = el('input(name="verify",type="password")')
      expect(element.tagName).to.equal('INPUT')
      expect(element.name).to.equal('verify')
      expect(element.type).to.equal('password')

    it 'anchor with id, classes, attribute value and inner text', ->
      tagSpec = '''
        input#verify-password.class1.class2(name="verify",type="password")
      '''
      element = el(tagSpec, 'baz')
      expect(element.tagName).to.equal('INPUT')
      expect(element.id).to.equal('verify-password')
      expect(element.className).to.equal('class1 class2')
      expect(element.name).to.equal('verify')
      expect(element.type).to.equal('password')

  it 'can set tag with attributes', ->
    element = el('a', href: '/foo/bar')
    expect(element.tagName).to.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))

  it 'does not add id attribute by default', ->
    expect(el().hasAttribute('id')).to.be.false

  it 'does not add className attribute by default', ->
    expect(el().hasAttribute('className')).to.be.false

  describe 'can set', ->
    it 'tag with id set through attributes', ->
      element = el('div#foo', id: 'bar')
      expect(element.tagName).to.equal('DIV')
      expect(element.id).to.equal('bar')

    it 'tag with className set through attributes', ->
      element = el('div.foo', className: 'bar')
      expect(element.tagName).to.equal('DIV')
      expect(element.className).to.equal('bar')

    it 'tag with tag attributes overridden', ->
      element = el('a(href="/foo/bar")', href: '/baz/quux')
      expect(element.tagName).to.equal('A')
      expect(element.href).to.match(new RegExp('/baz/quux'))

    it 'tag with attributes and inner text', ->
      element = el('a', { href: '/foo/bar' }, 'foo')
      expect(element.tagName).to.equal('A')
      expect(element.href).to.match(new RegExp('/foo/bar'))
      expect(element.innerHTML).to.equal('foo')

    it 'tag with attributes and single child element', ->
      child = el('span', 'foo')
      element = el('a', { href: '/foo/bar' }, child)
      expect(element.tagName).to.equal('A')
      expect(element.href).to.match(new RegExp('/foo/bar'))
      expect(element.innerHTML).to.equal('<span>foo</span>')

    it 'tag with attributes and children', ->
      element = el('a', { href: '/foo/bar' }, [ 'foo', ' ', 'bar' ])
      expect(element.tagName).to.equal('A')
      expect(element.href).to.match(new RegExp('/foo/bar'))
      expect(element.innerHTML).to.equal('foo bar')

    it 'style attributes with object', ->
      element = el 'div', style:
        left: '10px'
        marginLeft: '30px'
      expect(element.style.left).to.equal('10px')
      expect(element.style.marginLeft).to.equal('30px')

  describe 'can append', ->
    it 'element text as second argument', ->
      element = el('div', 'foo bar')
      expect(element.tagName).to.equal('DIV')
      expect(element.innerHTML).to.equal('foo bar')

    it 'undefined as second argument', ->
      element = el('div', undefined)
      expect(element.tagName).to.equal('DIV')
      expect(element.innerHTML).to.equal('')

    it 'element text as array of text', ->
      element = el('div', [ 'foo', ' ', 'bar' ])
      expect(element.tagName).to.equal('DIV')
      expect(element.innerHTML).to.equal('foo bar')

    it 'booleans or numbers as second argument', ->
      element = el('div', 10)
      expect(element.tagName).to.equal('DIV')
      expect(element.innerHTML).to.equal('10')

      element = el('div', true)
      expect(element.tagName).to.equal('DIV')
      expect(element.innerHTML).to.equal('true')

    it 'booleans or numbers as third argument', ->
      element = el('div', className: 'foo', 10)
      expect(element.tagName).to.equal('DIV')
      expect(element.className).to.equal('foo')
      expect(element.innerHTML).to.equal('10')

      element = el('div', className: 'foo', true)
      expect(element.tagName).to.equal('DIV')
      expect(element.className).to.equal('foo')
      expect(element.innerHTML).to.equal('true')

    it 'element child', ->
      element = el('div', el('em', 'foo'))
      expect(element.innerHTML).to.equal('<em>foo</em>')

    it 'array of children', ->
      element = el('div', [
        el('em', 'foo')
        ' bar'
      ])
      expect(element.innerHTML).to.equal('<em>foo</em> bar')

    it 'handles HTML text sanely', ->
      html = el('div', '<span>foo</span>').innerHTML
      expect(html).to.equal('&lt;span&gt;foo&lt;/span&gt;')

  it 'ignores null', ->
    element = el('div', null)
    expect(element.tagName).to.equal('DIV')
    expect(element.innerHTML).to.equal('')

  it 'ignores null in array', ->
    element = el('div', [
      'foo'
      null
      'bar'
    ])
    expect(element.tagName).to.equal('DIV')
    expect(element.innerHTML).to.equal('foobar')

  it 'can set element properties', ->
    html = el('div', el('button', disabled: false)).innerHTML
    expect(html).to.equal('<button></button>')

    html = el('div', el('button', disabled: true)).innerHTML
    expect(
      html is '<button disabled></button>' or
      html is '<button disabled=""></button>' or
      html is '<button disabled="disabled"></button>'
    ).to.be.true

  it 'can modify element setting text content', ->
    element = el('div', 'foo')
    el(element, 'bar')
    expect(element.innerHTML).to.equal('bar')

  it 'can modify setting HTML content', ->
    element = el('div', 'foo')
    el(element, el('em', 'foo'))
    expect(element.innerHTML).to.equal('<em>foo</em>')

  it 'can modify setting array of HTML content', ->
    element = el('div', 'foo')
    el(element, [
      el('em', 'foo')
      ' bar'
    ])
    expect(element.innerHTML).to.equal('<em>foo</em> bar')

  describe 'append children', ->
    it 'can append strings', ->
      element = el('div', 'foo')
      expect(element.innerHTML).to.equal('foo')

    it 'can append DOM elements', ->
      element = el('div', el('span', 'foo'))
      expect(element.innerHTML).to.equal('<span>foo</span>')

    it 'can append text nodes', ->
      element = el('div', el.text('foo'))
      expect(element.innerHTML).to.equal('foo')

    it 'can append Element instances', ->
      element = el('div', new el.Element('foo'))
      expect(element.innerHTML).to.equal('foo')

    it 'flattens out nested arrays', ->
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
      expect(html).to.equal('<span>foo</span><span>bar</span><span>baz</span>')

    it 'can use conditionals in array', ->
      html = el('div', [
        el('span', 'foo')
        if true then [
          el('span', 'this is true')
        ]
        if false then [
          el('span', 'this is false')
        ]
      ]).innerHTML
      expect(html).to.equal('<span>foo</span><span>this is true</span>')


describe 'elvis.css', ->
  it 'can create basic css properties', ->
    css = el.css(color: '#00f')
    expect(css).to.equal('color:#00f;')

  it 'can create multiple properties', ->
    css = el.css(color: '#00f', padding: '10px')
    expect(css).to.equal('color:#00f;padding:10px;')

  it 'can receive selectors', ->
    css = el.css(body: padding: '10px')
    expect(css).to.equal('body{padding:10px;}')


describe 'elvis.setAttr', ->
  it 'can set element id', ->
    element = el()
    el.setAttr(element, 'id', 'some-id')
    expect(element.id).to.equal('some-id')

  it 'can set element classList', ->
    element = el()
    el.setAttr(element, 'classList', ['foo', 'bar', 'baz'])
    expect(element.className).to.equals('foo bar baz')

  it 'can set element className', ->
    element = el()
    el.setAttr(element, 'className', 'class1 class2')
    expect(element.className).to.equal('class1 class2')

  it 'can set element innerHTML with html', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(element.innerHTML).to.equal('<em>foo</em> bar')

  it 'can set / get element text content', ->
    element = el()
    el.setAttr(element, 'text', '<em>foo</em> bar')
    expect(element.innerHTML).to.equal('&lt;em&gt;foo&lt;/em&gt; bar')

  it 'can set HTML content from DOM element', ->
    element = el()
    el.setAttr(element, 'html', el('em', 'foo'))
    expect(element.innerHTML).to.equal('<em>foo</em>')

  it 'can set multiple attributes', ->
    element = el()
    el.setAttr(element, id: 'some-id', className: 'class')
    expect(element.id).to.equal('some-id')
    expect(element.className).to.equal('class')

  it 'can set href on anchor', ->
    element = el('a')
    el.setAttr(element, href: '/foo/bar')
    expect(element.href).to.match(new RegExp('/foo/bar'))

  it 'can set className value from Element', ->
    element = el('span')
    el.setAttr(element, className: new el.Element('foo'))
    expect(element.className).to.equal('foo')

  it 'can set href value from Element', ->
    element = el('a')
    el.setAttr(element, href: new el.Element('/foo/bar'))
    expect(element.href).to.match(new RegExp('/foo/bar'))

  it 'can set disabled', ->
    element = el('button')

    el.setAttr(element, disabled: true)
    expect(element.disabled).to.be.true

    el.setAttr(element, disabled: false)
    expect(element.disabled).to.be.false


describe 'elvis.getAttr', ->
  it 'can get element id', ->
    expect(el.getAttr(el('#some-id'), 'id')).to.equal('some-id')

  it 'can get element className', ->
    expect(el.getAttr(el('.class1.class2'), 'className'))
      .to.equal('class1 class2')

  it 'can get element innerHTML with html', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(el.getAttr(element, 'html')).to.equal('<em>foo</em> bar')

  it 'can get element text content with text', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(el.getAttr(element, 'text')).to.equal('foo bar')


describe 'elvis.on', ->
  it 'can add event listeners', ->
    element = el('input')
    spy = sinon.spy()
    el.on(element, 'change', spy)
    element.dispatchEvent(createEvent('change'))
    expect(spy).to.be.calledOnce


describe 'elvis.text', ->
  it 'can create a text node', ->
    node = el.text('foo')
    expect(node.nodeType).to.equal(document.TEXT_NODE)
    expect(node.textContent).to.equal('foo')

  it 'can be appended to regularly with el', ->
    element = el('div', el.text('foo'))
    expect(element.innerHTML).to.equal('foo')


describe '.safe', ->
  it 'is a function', ->
    expect(el.safe).to.be.a('function')

  it 'returns an el.Element instance', ->
    isInstance = el.safe('foobar') instanceof el.Element
    expect(isInstance).to.be.true

  it 'returns an object with a proper .toString', ->
    value = el.safe('foobar') + ''
    expect(value).to.equal('foobar')

  it 'can be inject HTML into an elvis element', ->
    html = el('div', el.safe('foo<span>bar</span>baz')).innerHTML
    expect(html).to.equal('foo<span>bar</span>baz')

  it 'can insert HTML entities into an elvis element', ->
    html = el('div', el.safe('foo &mdash; bar')).innerHTML
    expect(html).to.equal('foo — bar')


describe '.infectString', ->
  it 'is a function', ->
    expect(el.infectString).to.be.a('function')

  it 'adds .safe to the String prototype', ->
    el.infectString()
    expect('foo'.safe).to.be.a('function')
    el.restoreString()

  it '"".safe returns an el.Element instance', ->
    el.infectString()
    isInstance = 'foo'.safe() instanceof el.Element
    expect(isInstance).to.be.true
    el.restoreString()

  it 'can be used to mark strings as safe', ->
    el.infectString()
    html = el('div', 'foo<span>bar</span>baz'.safe()).innerHTML
    expect(html).to.equal('foo<span>bar</span>baz')
    el.restoreString()

  it 'can create more elaborate markup', ->
    el.infectString()
    html = el('div', [
      'foo &mdash; bar'.safe()
      '<em>bold</em>'.safe()
      el('span', 'blergh')
    ]).innerHTML
    expect(html).to.equal('foo — bar<em>bold</em><span>blergh</span>')
    el.restoreString()


describe '.restoreString', ->
  it 'is a function', ->
    expect(el.restoreString).to.be.a('function')

  it 'removes .safe from the String prototype, restoring last value', ->
    oldSafe = ->
    String::safe = oldSafe
    el.infectString()
    el.restoreString()
    expect(String::safe).to.equal(oldSafe)
