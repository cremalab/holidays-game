View = require './view'
template = require './templates/hint'

module.exports = class HintView extends View
  className: 'hint'
  template: template
  y_offset: 10
  x_offset: 10
  initialize: ->
    super
    @listenTo @model, 'dispose', @dispose
  render: ->
    super
    setTimeout =>
      @el.style.position = 'absolute'
      rect = @el.getBoundingClientRect()
      obstruction = @model.get('obstruction')
      @el.style.zIndex = parseInt(obstruction.bottom)
      ob_width = obstruction.right - obstruction.left
      if @model.get('position') and @model.get('position') is 'right'
        @el.style.left = (obstruction.x + ob_width + @x_offset) + "px"
        @el.style.top = (@model.get('obstruction').y - @y_offset) + "px"
      else
        @el.style.left = (obstruction.x - (rect.width/4) ) + "px"
        @el.style.top = (@model.get('obstruction').y - (rect.height + @y_offset)) + "px"
    , 0
