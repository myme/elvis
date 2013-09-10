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
    element = el('div', el.bind(model, 'foo', reverseString))
    expect(element.innerHTML).to.equal('rab')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('xuuq')

  it 'can bind to attributes', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', className: el.bind(model, 'foo'))
    expect(element.className).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.className).to.equal('quux')

  it 'can bound to space separated attributes', ->
    model = new Backbone.Model(foo: 'bar', baz: 'quux')
    element = el('div', el.bind(model, 'foo baz'))
    expect(element.innerHTML).to.equal('bar quux')
    model.set(foo: 'rab')
    expect(element.innerHTML).to.equal('rab quux')
    model.set(baz: 'xuuq')
    expect(element.innerHTML).to.equal('rab xuuq')

  it 'can transform space separated attributes', ->
    model = new Backbone.Model(income: 9000, expenses: 7000)
    displayProfit = (i, e) -> "Profit: " + (i - e)
    element = el('div', el.bind(model, 'income expenses', displayProfit))
    expect(element.innerHTML).to.equal('Profit: 2000')
    model.set(income: 10000)
    expect(element.innerHTML).to.equal('Profit: 3000')
    model.set(expenses: 12000)
    expect(element.innerHTML).to.equal('Profit: -2000')
