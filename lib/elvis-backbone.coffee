el = @elvis


###
  Class: ModelBinding

  Description:
    Sub-class of `elvis.Element`. Handles data bindings using Backbone.Model.
    Supports multi-attribute one- and two-way bindings. An instance of
    `Binding` is returned by calling `model.bindTo`.
###
class ModelBinding extends el.Element
  constructor: (@model, attributes) ->
    if attributes not instanceof Array
      @attrs = [attributes]
    else
      @attrs = attributes

  ###
    Function: get

    Examples:
      elvis('div', model.bindTo('foo').get(function (foo) {
        return 'The current value of "foo" is ' + foo;
      }));

      elvis('div', model.bindTo(['foo', 'bar']).get(function (foo, bar) {
        return 'The current value of "foo" is ' + foo + ', ' +
               'and "bar" is ' + bar;
      }));

    Description:
      Defines a getter transform. The getter transform is passed the current
      values of the bound properties in the order they were defined. The getter
      transform must return a single value to be set on the target object.
  ###

  get: (transform) ->
    @_getTransform = transform
    this

  ###
    Function: set

    Examples:
      elvis('input', {
        value: model.bindTo(['firstName', 'lastName']).set(function (value) {
          var split = value.split(/\s+/);
          return {
            firstName: split[0],
            lastName: split[1],
          };
        })
      });

    Description:
      Defines a setter transform for two-way bindings. The setter transform
      must either return a single value if the binding has one attribute, or
      return an object containing the keys to be set on the model if the
      binding is on multiple attributes.
  ###

  set: (transform) ->
    @_setTransform = transform
    this

  getElement: ->
    if not @_element
      @_element = el.text()
      @setAttr(@_element, 'text')
    @_element

  getValue: ->
    values = (@model.get(attr) for attr in @attrs)
    transform = @_getTransform
    if transform
      transform(values...)
    else if values.length > 1
      values.join(' ')
    else
      values[0]

  setAttr: (obj, attribute) ->
    @toObj = obj
    @toAttr = attribute
    if obj.tagName is 'INPUT' and attribute is 'value'
      el.on(obj, 'change', => @updateModel(obj[attribute]))
    for attr in @attrs
      @model.on("change:#{attr}", @update, this)
    @update()

  update: ->
    el.setAttr(@toObj, @toAttr, @getValue())

  updateModel: (value) ->
    if @attrs.length > 1
      @model.set(@_setTransform(value))
    else
      @model.set(@attrs[0], value)


Backbone.Model::bindTo = (attributes) ->
  new ModelBinding(this, attributes)


class CollectionBinding extends el.Element
  constructor: (@collection, @attrs) ->

  getElement: ->
    if not @_element
      @_element = el.text('0')
    @_element


Backbone.Collection::bindTo = (attribute) ->
  new CollectionBinding(this, attribute)
