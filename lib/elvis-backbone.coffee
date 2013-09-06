el = @elvis

class Binding
  constructor: (@model, @attr) ->

  bindTo: (obj, attr) ->
    @model.on "change:#{@attr}", =>
      el.setAttr(obj, attr, @getValue())

  getValue: ->
    @model.get(@attr)


el.bind = (model, attr) ->
  new Binding(model, attr)


el.registerPlugin (element) ->
  if element instanceof Binding
    binding = element
    node = el.text(binding.getValue())
    binding.bindTo(node, 'text')
    return node
  element
