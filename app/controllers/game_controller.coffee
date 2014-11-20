MapView     = require 'views/map_view'
mediator    = require 'lib/mediator'
EventBroker = require 'lib/event_broker'
Player      = require 'models/player'
Avatar      = require 'views/avatar'
utils       = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  constructor: ->
    @setupMap()
  setupMap: ->
    @mapView = new MapView
      className: 'map'
      el: document.getElementById("map")
      autoRender: true
    @addPlayer()

  addPlayer: ->
    player = new Player
      id: 1
      name: "Ross"
      x_position: 400
      y_position: 400
    avatar = new Avatar
      model: player

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition


    @mapView.spawnPlayer(player, avatar)