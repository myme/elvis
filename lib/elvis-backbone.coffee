el = @elvis

class Binding extends el.Element
  constructor: (@model, @attr, @transform) ->

  bindTo: (obj, attr) ->
    @toObj = obj
    @toAttr = attr
    @model.on("change:#{@attr}", @update, this)
    this

  getElement: ->
    if not @_element
      @_element = el.text(@getValue())
      @bindTo(@_element, 'text')
    @_element

  getValue: ->
    value = @model.get(@attr)
    if @transform then @transform(value) else value

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())


el.bind = (model, attr, transform) ->
  new Binding(model, attr, transform)
