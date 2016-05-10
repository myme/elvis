if typeof exports is 'object' and typeof exports.nodeName isnt 'string'
  Backbone = require('backbone')
  el = require('elvis')
else
  Backbone = window.Backbone
  el = window.elvis


virtual = (fname) -> ->
  throw new Exception("#{fname} must be implemented in sub class")


###
  Class: Binding

  Description:
    Sub-class of `elvis.Element`. Handles data bindings in a generic way.
    Supports multi-attribute one- and two-way bindings.
###
class Binding extends el.Element
  constructor: (@context, attributes) ->
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

  getValue: virtual('getValue')

  _getValue: ->
    values = (@getValue(attr) for attr in @attrs)
    if transform = @_getTransform
      transform.call(@context, values...)
    else if values.length > 1
      values.join(' ')
    else
      values[0]

  setAttr: (obj, path...) ->
    @toObj = obj
    @toAttr = path
    if obj.tagName is 'INPUT' and path[0] is 'value'
      el.on(obj, 'change', => @updateModel(obj.value))
    @subscribe(attr) for attr in @attrs
    @update()

  setValue: virtual('setValue')

  subscribe: virtual('subscribe')

  update: ->
    attr = @_getValue()
    for part in @toAttr.slice().reverse()
      tmp = {}
      tmp[part] = attr
      attr = tmp
    el.setAttr(@toObj, attr)

  updateModel: (value) ->
    if @attrs.length > 1
      @setValue(@_setTransform(value))
    else
      @setValue(@attrs[0], value)


class ModelBinding extends Binding
  getValue: (args...) -> @context.get(args...)
  setValue: (args...) -> @context.set(args...)
  subscribe: (attr) ->
    @context.on("change:#{attr}", @update, this)


Backbone.Model::bindTo = ->
  new ModelBinding(this, arguments...)


class ViewBinding extends Binding
  getValue: (args...) -> @context.model.get(args...)
  setValue: (args...) -> @context.model.set(args...)
  subscribe: (attr) ->
    @context.listenTo(@context.model, "change:#{attr}", => @update())


Backbone.View::bindTo = ->
  new ViewBinding(this, arguments...)
