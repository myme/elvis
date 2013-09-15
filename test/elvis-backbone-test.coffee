el = @elvis

createEvent = (type) ->
  event = document.createEvent('HTMLEvents')
  event.initEvent(type, true, false)
  event

describe 'Elvis Backbone.Model', ->
  it 'can handle basic bindings', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', model.bindTo('foo'))
    expect(element.innerHTML).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('quux')

  it 'can handle binding in array', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', [ model.bindTo('foo') ])
    expect(element.innerHTML).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('quux')

  it 'can transform binding value', ->
    model = new Backbone.Model(foo: 'bar')
    reverseString = (input) -> input.split('').reverse().join('')
    element = el('div', model.bindTo('foo').fromModel(reverseString))
    expect(element.innerHTML).to.equal('rab')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('xuuq')

  it 'can bind to attributes', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', className: model.bindTo('foo'))
    expect(element.className).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.className).to.equal('quux')

  it 'can bound to space separated attributes', ->
    model = new Backbone.Model(foo: 'bar', baz: 'quux')
    element = el('div', model.bindTo('foo baz'))
    expect(element.innerHTML).to.equal('bar quux')
    model.set(foo: 'rab')
    expect(element.innerHTML).to.equal('rab quux')
    model.set(baz: 'xuuq')
    expect(element.innerHTML).to.equal('rab xuuq')

  it 'can transform space separated attributes', ->
    model = new Backbone.Model(income: 9000, expenses: 7000)
    displayProfit = (i, e) -> "Profit: " + (i - e)
    binding = model.bindTo('income expenses').fromModel(displayProfit)
    element = el('div', binding)
    expect(element.innerHTML).to.equal('Profit: 2000')
    model.set(income: 10000)
    expect(element.innerHTML).to.equal('Profit: 3000')
    model.set(expenses: 12000)
    expect(element.innerHTML).to.equal('Profit: -2000')

  it 'can do two-way binding on input fields', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('input', type: 'text', value: model.bindTo('foo'))
    expect(element.value).to.equal('bar')
    element.value = 'quux'
    element.dispatchEvent(createEvent('change'))
    expect(model.get('foo')).to.equal('quux')
    model.set(foo: 'bar')
    expect(element.value).to.equal('bar')

#   it 'can handle short-hand input binding', ->
#     model = new Backbone.Model(foo: 'bar')
#     element = el('input', model.bindTo('foo'))
#     expect(element.value).to.equal('bar')
#     element.value = 'quux'
#     element.dispatchEvent(createEvent('change'))
#     expect(model.get('foo')).to.equal('quux')
#     model.set(foo: 'bar')
#     expect(element.value).to.equal('bar')

  it 'can transform value on input change', ->
    model = new Backbone.Model()
    element = el 'input',
      type: 'text',
      value: model.bindTo('firstName lastName').toModel((v) -> v.split(/\s+/))
    element.value = 'John Doe'
    element.dispatchEvent(createEvent('change'))
    expect(model.get('firstName')).to.equal('John')
    expect(model.get('lastName')).to.equal('Doe')
