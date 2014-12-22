# Adaptation of http://www.pubnub.com/blog/multiuser-draw-html5-canvas-tutorial/

Modal    = require 'views/modal_view'
View     = require 'views/view'
mediator = require 'lib/mediator'

module.exports = class WhiteBoard extends View
  isActive: false
  template: require 'views/templates/whiteboard'
  render: ->
    super
    setTimeout =>
      @setupCanvas()
      for path in @model.get('plots')
        @drawOnCanvas path
    , 0

  setupCanvas: ->
    @listenTo @model, "change:plots", =>
      @drawFromStream()
    @canvas = document.getElementById('whiteboardCanvas')
    @ctx = @canvas.getContext('2d')
    @ctx.lineWidth = '1'

  drawOnCanvas: (plots) ->
    if plots.length
      @ctx.beginPath()
      @ctx.moveTo plots[0].x, plots[0].y
      i = 1

      while i < plots.length
        @ctx.lineTo plots[i].x, plots[i].y
        i++
      @ctx.stroke()
      return

  drawFromStream: ->
    @ctx.beginPath()
    for path in @model.get('plots')
      @drawOnCanvas path
    return