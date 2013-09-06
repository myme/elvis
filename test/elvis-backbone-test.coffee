el = @elvis

describe 'el.backbone.model', ->
  it 'can handle basic bindings', ->
    model = new Backbone.Model(foo: 'bar')
    element = el('div', [ el.bind(model, 'foo') ])
    expect(element.innerHTML).to.be.equal('bar')
    model.set(foo: 'quux')
    expect(element.innerHTML).to.be.equal('quux')
