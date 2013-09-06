el = @elvis

describe 'el.backbone.model', ->
  it 'can handle basic bindings', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', el.bind(model, 'foo'))
    expect(element.innerHTML).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('quux')

  it 'can handle binding in array', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', [ el.bind(model, 'foo') ])
    expect(element.innerHTML).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('quux')

  it 'can transform binding value', ->
    model = new Backbone.Model(foo: 'bar')
    spy = sinon.spy()
    element = el('div', [ el.bind(model, 'foo', spy) ])
    expect(spy).to.be.calledOnce
    expect(spy).to.be.calledWith('bar')
    model.set(foo: 'quux')
    expect(spy).to.be.calledWith('quux')

  it 'can bind to attributes', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', className: el.bind(model, 'foo'))
    expect(element.className).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.className).to.equal('quux')
