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
    element = el('div', model.bindTo('foo').get(reverseString))
    expect(element.innerHTML).to.equal('rab')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.equal('xuuq')

  it 'can bind to attributes', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', className: model.bindTo('foo'))
    expect(element.className).to.equal('bar')
    model.set(foo: 'quux')
    expect(element.className).to.equal('quux')

  it 'can bind to boolean attribute', ->
    model = new Backbone.Model(disabled: false)
    element = el('div', el('button', disabled: model.bindTo('disabled')))
    expect(element.innerHTML).to.equal('<button></button>')

    model.set(disabled: true)
    html = element.innerHTML
    expect(
      html is '<button disabled></button>' or
      html is '<button disabled=""></button>' or
      html is '<button disabled="disabled"></button>'
    ).to.be.true

  it 'can bound to multiple attributes', ->
    model = new Backbone.Model(foo: 'bar', baz: 'quux')
    element = el('div', model.bindTo(['foo', 'baz']))
    expect(element.innerHTML).to.equal('bar quux')
    model.set(foo: 'rab')
    expect(element.innerHTML).to.equal('rab quux')
    model.set(baz: 'xuuq')
    expect(element.innerHTML).to.equal('rab xuuq')

  it 'can transform space separated attributes', ->
    model = new Backbone.Model(income: 9000, expenses: 7000)
    displayProfit = (i, e) -> "Profit: " + (i - e)
    binding = model.bindTo(['income', 'expenses']).get(displayProfit)
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

  it 'can transform value on input change with setter transform', ->
    model = new Backbone.Model()
    element = el 'input',
      type: 'text',
      value: model.bindTo(['firstName', 'lastName']).set (value) ->
        [first, last] = value.split(/\s+/)
        firstName: first
        lastName: last
    element.value = 'John Doe'
    element.dispatchEvent(createEvent('change'))
    expect(model.get('firstName')).to.equal('John')
    expect(model.get('lastName')).to.equal('Doe')

  it 'can bind using bindTo in a Backbone View', ->
    class View extends Backbone.View
      render: ->
        el(@el, @bindTo('value'))
        this

    model = new Backbone.Model(value: 'foo')
    view = new View(model: model).render()

    expect(view.el.innerHTML).to.equal('foo')

    model.set(value: 'bar')
    expect(view.el.innerHTML).to.equal('bar')

  it 'removes Backbone View bindings when the view is destroyed', ->
    binding = null
    class View extends Backbone.View
      render: ->
        el(@el, binding = @bindTo('value'))
        this

    model = new Backbone.Model(value: 'foo')
    view = new View(model: model).render()
    spy = sinon.spy(binding, 'update')

    model.set(value: 'bar')
    expect(spy).to.be.calledOnce
    spy.reset()

    view.remove()
    model.set(value: 'quux')
    expect(spy).to.not.be.called
