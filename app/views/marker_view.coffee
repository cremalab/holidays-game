View = require 'views/view'

module.exports = class MarkerView extends View
  template: require './templates/marker'
  className: 'marker'
  render: ->
    super
    @el.style.color = @model.get('color')
    @el.addEventListener 'click', =>
      @model.trigger 'chosen', @model.get('color')
