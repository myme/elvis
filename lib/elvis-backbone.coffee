el = @elvis

class Binding
  constructor: (@model, @attr, @transform) ->

  bindTo: (obj, attr) ->
    @model.on "change:#{@attr}", =>
      el.setAttr(obj, attr, @getValue())

  getValue: ->
    value = @model.get(@attr)
    if @transform then @transform(value) else value


el.bind = (model, attr, transform) ->
  new Binding(model, attr, transform)


el.registerPlugin (element) ->
  if element instanceof Binding
    binding = element
    node = el.text(binding.getValue())
    binding.bindTo(node, 'text')
    return node
  element
