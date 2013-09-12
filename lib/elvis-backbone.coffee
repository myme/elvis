el = @elvis


class Binding extends el.Element
  constructor: (@model, attributes, @transform) ->
    @attrs = attributes.split(/\s+/)

  getElement: ->
    if not @_element
      @_element = el.text()
      @setAttr(@_element, 'text')
    @_element

  getValue: ->
    values = (@model.get(attr) for attr in @attrs)
    if @transform then @transform(values...) else values.join(' ')

  setAttr: (obj, attribute) ->
    @toObj = obj
    @toAttr = attribute
    if obj.tagName is 'INPUT' and attribute is 'value'
      el.on obj, 'change', =>
        @model.set(@attrs[0], obj[attribute])
    for attr in @attrs
      @model.on("change:#{attr}", @update, this)
    @update()

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())


Backbone.Model::bindTo = (attributes, transform) ->
  new Binding(this, attributes, transform)
