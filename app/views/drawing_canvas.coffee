View = require './view'

module.exports = class DrawingCanvas extends View
  color: "#363f59"
  lineWidth: 50
  gameLoopInt: 2000
  plotCleanCount: 5
  cleanup: false

  initialize: ->
    super
    @plots = []
    if @cleanup
      setInterval =>
        @cleanupPlots()
      , @gameLoopInt

  render: ->
    super
    @ctx = @el.getContext('2d')
    @ctx.globalAlpha = 0.5
    @ctx.globalCompositeOperation = "xor"
    @ctx.strokeStyle = @color
    @ctx.lineWidth = @lineWidth
    @ctx.lineCap = 'round'
    @ctx.lineJoin = 'round'

  drawOnCanvas: (plots) ->
    if plots.length
      @ctx.beginPath()
      @ctx.moveTo plots[0].x, plots[0].y
      for plot, i in plots
        @ctx.lineTo plot.x, plot.y
      @ctx.stroke()
      # @ctx.closePath()

  # Extend an avatar's trail
  addPointToTrail: (plots, player, avatar) ->
    start = plots[0]
    end   = plots[plots.length-1]

    @ctx.beginPath()
    @ctx.moveTo start.x, start.y
    @ctx.lineTo end.x, end.y
    @ctx.stroke()
    @ctx.closePath()
    @plots.push start
    @plots.push end

  # Drop old snow trail plots and redraw
  cleanupPlots: ->
    @plots.splice(0, @plotCleanCount)
    @ctx.restore()
    @ctx.clearRect(0,0, @el.width, @el.height)
    @drawOnCanvas(@plots)

