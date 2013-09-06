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
    reverseString = (input) -> input.split('').reverse().join('')
    element = el('div', [ el.bind(model, 'foo', reverseString) ])
    expect(element.innerHTML).to.equal('rab')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('xuuq')

  it 'can bind to attributes', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', className: el.bind(model, 'foo'))
    expect(element.className).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.className).to.equal('quux')
