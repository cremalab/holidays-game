View = require './view'
template = require './templates/hint'

module.exports = class HintView extends View
  className: 'hint'
  template: template
  initialize: ->
    super
    @listenTo @model, 'dispose', @dispose
  render: ->
    super
    @el.style.position = 'absolute'
    @el.style.zIndex = '100000'
    @el.style.left = @model.get('obstruction').x + "px"
    @el.style.top = @model.get('obstruction').y + "px"