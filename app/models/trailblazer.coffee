Model = require 'models/model'

module.exports = class Trailblazer extends Model
  initialize: (options) ->
    super
    @canvas = options.canvas
    @avatar = options.avatar
    @player = @avatar.model
    @plots  = []
    @plot_count = 0

    @listenTo @player, 'change:x_position change:y_position', (x,y) =>
      @plot_count++

      # if @plot_count % 5 is 0
      plot =
        x: @player.get('x_position')
        y: @player.get('y_position')
      @plots.push(plot)
      @cleanupPlots()
      @canvas.addPointToTrail @getStartEnd(@plots), @player, @avatar

  getStartEnd: (plots) ->
    if plots.length > 1
      last   = plots[plots.length - 2]
      latest = plots[plots.length - 1]
    else
      last =
        x: @player.get('x_position') + (@avatar.width/1.65)
        y: @player.get('y_position') + (@avatar.height)
      if plots.length
        latest = plots[plots.length]
        latest = last unless latest

    latest.x = latest.x + (@avatar.width/1.65)
    latest.y = latest.y + (@avatar.height)
    return [last, latest]

  cleanupPlots: ->
    if @plots.length > 10
      @plots.shift()
