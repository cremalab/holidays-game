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
    obstruction = @model.get('obstruction')
    ob_width = obstruction.right - obstruction.left
    @el.style.left = (obstruction.x - (ob_width/2)) + "px"
    @el.style.top = (@model.get('obstruction').y) + "px"