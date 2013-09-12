describe 'Elvis context', ->
  it 'does not contaminate the global scope', ->
    expect(window.DIV).to.be.undefined

  it 'can create basic HTML with injected scope', ->
    html = do el.htmlContext -> DIV SPAN 'foo'
    expect(html.innerHTML).to.equal('<span>foo</span>')

  it 'can create HTML elements with children', ->
    html = do el.htmlContext ->
      UL [
        LI '1'
        LI '2'
        LI '3'
      ]
    expect(html.innerHTML).to.equal('<li>1</li><li>2</li><li>3</li>')

  it 'can handle arguments', ->
    fn = el.htmlContext (text) -> DIV text
    expect(fn('foo').innerHTML).to.equal('foo')

  it 'can reference object instance variables', ->
    obj =
      text: 'foo'
      render: el.htmlContext -> DIV SPAN @text
    html = obj.render()
    expect(html.innerHTML).to.equal('<span>foo</span>')

  it 'can handle Backbone.Model bindings', ->
    obj =
      model: new Backbone.Model(foo: 'bar')
      render: el.htmlContext -> DIV @model.bindTo('foo')
    html = obj.render()
    expect(html.innerHTML).to.equal('bar')
    obj.model.set(foo: 'quux')
    expect(html.innerHTML).to.equal('quux')
