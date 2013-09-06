el = @elvis

class Binding
  constructor: (@model, @attr) ->

  getValue: ->
    @model.get(@attr)


el.bind = (model, attr) ->
  new Binding(model, attr)


el.registerPlugin (element) ->
  if element instanceof Binding
    binding = element
    return binding.getValue()
  element
