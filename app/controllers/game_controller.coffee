MapView       = require 'views/map_view'
mediator      = require 'lib/mediator'
EventBroker   = require 'lib/event_broker'
Player        = require 'models/player'
Avatar        = require 'views/avatar'
DrawingCanvas = require 'views/drawing_canvas'
Trailblazer   = require 'models/trailblazer'
Weather       = require 'lib/weather'
utils         = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  constructor: ->
    @setupMap()
    @setupCanvas()
    @addPlayer()

  setupMap: ->
    @mapView = new MapView
      className: 'map'
      el: document.getElementById("map")
      autoRender: true
    Weather.snow('snowCanvas')

  setupCanvas: ->
    @canvas = new DrawingCanvas
      el: document.getElementById('drawCanvas')
      autoRender: true

  addPlayer: ->
    player = new Player
      id: 1
      name: "Ross"
      x_position: 400
      y_position: 400
    avatar = new Avatar
      model: player

    avatar.trailblazer = new Trailblazer
      player: player
      avatar: avatar
      canvas: @canvas

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition

    @mapView.spawnPlayer(player, avatar)