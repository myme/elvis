el = @elvis

describe 'el', ->
  it 'can create div by default', ->
    expect(el().tagName).to.be.equal('DIV')

  it 'can create an input field', ->
    expect(el('input').tagName).to.be.equal('INPUT')

  it 'can create a span', ->
    expect(el('span').tagName).to.be.equal('SPAN')

  it 'does not add id attribute by default', ->
    expect(el().hasAttribute('id')).to.be.false

  it 'does not add className attribute by default', ->
    expect(el().hasAttribute('className')).to.be.false

  it 'can create div with class', ->
    element = el('.class')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.className).to.be.equal('class')

  it 'can create div with multiple classes', ->
    element = el('.class1.class2')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.className).to.be.equal('class1 class2')

  it 'can create div with id', ->
    element = el('#some-element')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.id).to.be.equal('some-element')

  it 'can create div with id and classes', ->
    element = el('.class1#some-element.class2')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.id).to.be.equal('some-element')
    expect(element.className).to.be.equal('class1 class2')

  it 'can create span with class', ->
    element = el('span.class')
    expect(element.tagName).to.be.equal('SPAN')
    expect(element.className).to.be.equal('class')

  it 'can create anchor with href', ->
    element = el('a(href="/foo/bar")', 'baz')
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))
    expect(element.innerHTML).to.be.equal('baz')

  it 'can create input with name and type', ->
    element = el('input(name="verify",type="password")')
    expect(element.tagName).to.be.equal('INPUT')
    expect(element.name).to.be.equal('verify')
    expect(element.type).to.be.equal('password')

  it 'can create anchor with id, classes, attribute value and inner text', ->
    tagSpec = '''
      input#verify-password.class1.class2(name="verify",type="password")
    '''
    element = el(tagSpec, 'baz')
    expect(element.tagName).to.be.equal('INPUT')
    expect(element.id).to.be.equal('verify-password')
    expect(element.className).to.be.equal('class1 class2')
    expect(element.name).to.be.equal('verify')
    expect(element.type).to.be.equal('password')

  it 'can set tag with attributes', ->
    element = el('a', href: '/foo/bar')
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))

  it 'can set tag with id set through attributes', ->
    element = el('div#foo', id: 'bar')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.id).to.be.equal('bar')

  it 'can set tag with className set through attributes', ->
    element = el('div.foo', className: 'bar')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.className).to.be.equal('bar')

  it 'can set tag with tag attributes overridden', ->
    element = el('a(href="/foo/bar")', href: '/baz/quux')
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/baz/quux'))

  it 'can set tag with attributes and inner text', ->
    element = el('a', { href: '/foo/bar' }, 'foo')
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))
    expect(element.innerHTML).to.be.equal('foo')

  it 'can set tag with attributes and single child element', ->
    child = el('span', 'foo')
    element = el('a', { href: '/foo/bar' }, child)
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))
    expect(element.innerHTML).to.be.equal('<span>foo</span>')

  it 'can set tag with attributes and children', ->
    element = el('a', { href: '/foo/bar' }, [ 'foo', ' ', 'bar' ])
    expect(element.tagName).to.be.equal('A')
    expect(element.href).to.match(new RegExp('/foo/bar'))
    expect(element.innerHTML).to.be.equal('foo bar')

  it 'can append element text as second argument', ->
    element = el('div', 'foo bar')
    expect(element.tagName).to.be.equal('DIV')
    expect(element.innerHTML).to.be.equal('foo bar')

  it 'can append element text as array of text', ->
    element = el('div', [ 'foo', ' ', 'bar' ])
    expect(element.tagName).to.be.equal('DIV')
    expect(element.innerHTML).to.be.equal('foo bar')

  it 'can append element child', ->
    element = el('div', el('em', 'foo'))
    expect(element.innerHTML).to.be.equal('<em>foo</em>')

  it 'can append array of children', ->
    element = el('div', [
      el('em', 'foo')
      ' bar'
    ])
    expect(element.innerHTML).to.be.equal('<em>foo</em> bar')

  it 'ignores null', ->
    element = el('div', null)
    expect(element.tagName).to.be.equal('DIV')
    expect(element.innerHTML).to.be.equal('')

  it 'ignores null in array', ->
    element = el('div', [
      'foo'
      null
      'bar'
    ])
    expect(element.tagName).to.be.equal('DIV')
    expect(element.innerHTML).to.be.equal('foobar')

  it 'can modify element setting text content', ->
    element = el('div', 'foo')
    el(element, 'bar')
    expect(element.innerHTML).to.be.equal('bar')

  it 'can modify setting HTML content', ->
    element = el('div', 'foo')
    el(element, el('em', 'foo'))
    expect(element.innerHTML).to.be.equal('<em>foo</em>')

  it 'can modify setting array of HTML content', ->
    element = el('div', 'foo')
    el(element, [
      el('em', 'foo')
      ' bar'
    ])
    expect(element.innerHTML).to.be.equal('<em>foo</em> bar')


describe 'el.css', ->
  it 'can create basic css properties', ->
    css = el.css(color: '#00f')
    expect(css).to.be.equal('color:#00f;')

  it 'can create multiple properties', ->
    css = el.css(color: '#00f', padding: '10px')
    expect(css).to.be.equal('color:#00f;padding:10px;')

  it 'can receive selectors', ->
    css = el.css(body: padding: '10px')
    expect(css).to.be.equal('body{padding:10px;}')


describe 'el.setAttr', ->
  it 'can set element id', ->
    element = el()
    el.setAttr(element, 'id', 'some-id')
    expect(element.id).to.be.equal('some-id')

  it 'can set element className', ->
    element = el()
    el.setAttr(element, 'className', 'class1 class2')
    expect(element.className).to.be.equal('class1 class2')

  it 'can set element innerHTML with html', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(element.innerHTML).to.be.equal('<em>foo</em> bar')

  it 'can set / get element text content', ->
    element = el()
    el.setAttr(element, 'text', '<em>foo</em> bar')
    expect(element.innerHTML).to.be.equal('&lt;em&gt;foo&lt;/em&gt; bar')

  it 'can set HTML content from DOM element', ->
    element = el()
    el.setAttr(element, 'html', el('em', 'foo'))
    expect(element.innerHTML).to.be.equal('<em>foo</em>')

  it 'can set multiple attributes', ->
    element = el()
    el.setAttr(element, id: 'some-id', className: 'class')
    expect(element.id).to.be.equal('some-id')
    expect(element.className).to.be.equal('class')

  it 'can set href on anchor', ->
    element = el('a')
    el.setAttr(element, href: '/foo/bar')
    expect(element.href).to.match(new RegExp('/foo/bar'))


describe 'el.getAttr', ->
  it 'can get element id', ->
    expect(el.getAttr(el('#some-id'), 'id')).to.be.equal('some-id')

  it 'can get element className', ->
    expect(el.getAttr(el('.class1.class2'), 'className'))
      .to.be.equal('class1 class2')

  it 'can get element innerHTML with html', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(el.getAttr(element, 'html')).to.be.equal('<em>foo</em> bar')

  it 'can get element text content with text', ->
    element = el()
    el.setAttr(element, 'html', '<em>foo</em> bar')
    expect(el.getAttr(element, 'text')).to.be.equal('foo bar')


describe 'el.text', ->
  it 'can create a text node', ->
    node = el.text('foo')
    expect(node.nodeType).to.be.equal(document.TEXT_NODE)
    expect(node.textContent).to.be.equal('foo')

  it 'can be appended to regularly with el', ->
    element = el('div', el.text('foo'))
    expect(element.innerHTML).to.be.equal('foo')


describe 'el.registerPlugin', ->
  it 'can register plugin called on appended elements', ->
    el.registerPlugin(spy = sinon.spy())
    el('div', [ 'foo', 'bar' ])
    expect(spy).to.be.calledTwice
    expect(spy).to.be.calledWith('foo')
    expect(spy).to.be.calledWith('bar')

  it 'can register plugin replacing elements', ->
    children = [
      el('span', 'baz')
      el('span', 'quux')
    ]
    el.registerPlugin((child) -> children.shift())
    expect(el('div', [ 'foo', 'bar' ]).innerHTML)
      .to.be.equal('<span>baz</span><span>quux</span>')


describe 'el.resetPlugins', ->
  it 'removes registered plugins', ->
    el.registerPlugin(spy = sinon.spy())
    el.resetPlugins()
    el('div', [ 'foo', 'bar' ])
    expect(spy).not.to.be.called
