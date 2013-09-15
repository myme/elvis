el = @elvis


class Binding extends el.Element
  constructor: (@model, attributes) ->
    @attrs = attributes.split(/\s+/)

  fromModel: (transform) ->
    @_fromModelTransform = transform
    this

  getElement: ->
    if not @_element
      @_element = el.text()
      @setAttr(@_element, 'text')
    @_element

  getValue: ->
    values = (@model.get(attr) for attr in @attrs)
    transform = @_fromModelTransform
    if transform then transform(values...) else values.join(' ')

  setAttr: (obj, attribute) ->
    @toObj = obj
    @toAttr = attribute
    if obj.tagName is 'INPUT' and attribute is 'value'
      el.on(obj, 'change', => @updateModel(obj[attribute]))
    for attr in @attrs
      @model.on("change:#{attr}", @update, this)
    @update()

  toModel: (transform) ->
    @_toModelTransform = transform
    this

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())

  updateModel: (value) ->
    value = if transform = @_toModelTransform then transform(value) else value
    value = [value] if value not instanceof Array
    @model.set(attr, value[idx]) for attr, idx in @attrs


Backbone.Model::bindTo = (attributes) ->
  new Binding(this, attributes)
