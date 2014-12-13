View = require './view'
template = require './templates/hint'

module.exports = class HintView extends View
  className: 'hint'
  template: template
  render: ->
    super
    console.log @model.get('obstruction').x
    @el.style.position = 'absolute'
    @el.style.width = '300px'
    @el.style.zIndex = '100000'
    @el.style.left = @model.get('obstruction').x + "px"
    @el.style.top = @model.get('obstruction').y + "px"