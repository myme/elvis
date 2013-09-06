el = @elvis


class Binding extends el.Element
  constructor: (@model, @attr, @transform) ->

  getElement: ->
    if not @_element
      @_element = el.text()
      @setAttr(@_element, 'text')
    @_element

  getValue: ->
    value = @model.get(@attr)
    if @transform then @transform(value) else value

  setAttr: (obj, attr) ->
    @toObj = obj
    @toAttr = attr
    @model.on("change:#{@attr}", @update, this)
    @update()

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())


el.bind = (model, attr, transform) ->
  new Binding(model, attr, transform)
