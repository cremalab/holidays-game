Model = require 'models/model'

module.exports = class SnowDrawer extends Model
  initialize: (options) ->
    super
    @canvas = options.canvas
    @player = options.player
    @avatar = options.avatar
    @canvas.listenTo @avatar, 'playerMove', @canvas.draw