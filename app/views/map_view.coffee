View = require './view'
template = require './templates/map'

module.exports = class MapView extends View
  template: template
  className: "map"

  spawnPlayer: (player, avatar) ->
    avatar.container = @el
    avatar.render()