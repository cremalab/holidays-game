View = require './view'

module.exports = class DrawingCanvas extends View
  color: 'yellowgreen'
  initialize: ->
    super
    @plots = []

  render: ->
    super
    @ctx = @el.getContext('2d')
    @ctx.strokeStyle = 'yellowgreen'
    @ctx.lineWidth = '3'
    @ctx.lineCap = 'round'
    @ctx.lineJoin = 'round'

    @plots = []

  draw: (player, avatar) ->
    # return unless @isActive
    
    x = player.get('x_position')
    y = player.get('y_position')
    @plots.push
      x: x
      y: y

    @drawOnCanvas @plots

  drawOnCanvas: ->
    @ctx.beginPath()
    @ctx.moveTo @plots[0].x, @plots[0].y
    i = 1
    for plot, i in @plots
      @ctx.lineTo plot.x, plot.y
    @ctx.stroke()

  endDraw: (e) ->
    @plots = []