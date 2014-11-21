Model = require 'models/model'

module.exports = class Trailblazer extends Model
  initialize: (options) ->
    super
    @canvas = options.canvas
    @player = options.player
    @avatar = options.avatar
    @plots  = []
    @plot_count = 0

    @listenTo @avatar, 'playerMove', (player, avatar) =>
      @plot_count++

      if @plot_count % 5 is 0
        plot = 
          x: player.get('x_position')
          y: player.get('y_position')
        @plots.push(plot)

        @canvas.addPointToTrail @getStartEnd(@plots), @player, @avatar

  getStartEnd: (plots) ->
    if plots.length > 1
      last   = plots[plots.length - 2]
      latest = plots[plots.length - 1]
    else
      last =
        x: @player.get('x_position')
        y: @player.get('y_position')
      if plots.length
        latest = plots[plots.length]
        latest = last unless latest 

    latest.x = latest.x + (@avatar.width/2)
    latest.y = latest.y + (@avatar.height/2)
    return [last, latest]

