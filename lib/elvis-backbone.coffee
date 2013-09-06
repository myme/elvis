el = @elvis

class Binding
  constructor: (@model, @attr, @transform) ->

  bindTo: (obj, attr) ->
    @toObj = obj
    @toAttr = attr
    @model.on("change:#{@attr}", @update, this)
    this

  getValue: ->
    value = @model.get(@attr)
    if @transform then @transform(value) else value

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())


el.bind = (model, attr, transform) ->
  new Binding(model, attr, transform)


el.registerPlugin
  predicate: (element) ->
    element instanceof Binding
  handler: (element) ->
    element.bindTo(node = el.text(), 'text').update()
    node
