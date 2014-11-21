View = require './view'

module.exports = class DrawingCanvas extends View
  color: "#363f59"
  lineWidth: 50

  initialize: ->
    super
    @plots = []

  render: ->
    super
    @ctx = @el.getContext('2d')
    @ctx.globalAlpha = 0.5
    @ctx.globalCompositeOperation = "xor"
    @ctx.strokeStyle = @color
    @ctx.lineWidth = @lineWidth
    @ctx.lineCap = 'round'
    @ctx.lineJoin = 'round'

    @plots = []

  draw: (player, avatar) ->
    # return unless @isActive
    
    x = player.get('x_position') + (avatar.width/2)
    y = player.get('y_position') + (avatar.height/2)
    @plots.push
      x: x
      y: y

    @drawOnCanvas @plots

  drawOnCanvas: ->
    @ctx.beginPath()
    @ctx.moveTo @plots[0].x, @plots[0].y
    for plot, i in @plots
      @ctx.lineTo plot.x, plot.y
    # console.log @ctx
    @ctx.stroke()
    @ctx.closePath()

  endDraw: (e) ->
    @plots = []

  # Extend an avatar's trail
  addPointToTrail: (plots, player, avatar) ->
    start = plots[0]
    end   = plots[plots.length-1]

    @ctx.beginPath()
    @ctx.moveTo start.x, start.y
    @ctx.lineTo end.x, end.y
    @ctx.stroke()
    @ctx.closePath()

