MapView       = require 'views/map_view'
mediator      = require 'lib/mediator'
EventBroker   = require 'lib/event_broker'
Player        = require 'models/player'
Avatar        = require 'views/avatar'
DrawingCanvas = require 'views/drawing_canvas'
Trailblazer   = require 'models/trailblazer'
Weather       = require 'lib/weather'
Notifier      = require 'models/notifier'
utils         = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  constructor: ->
    @notifier = new Notifier
    @setupMap()
    @setupCanvas()
    @createPlayer()
    @subscribeEvent 'addPlayer', @addPlayer

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

  createPlayer: ->
    player = new Player
      id: 1
      name: Date.now()
      x_position: 400
      y_position: 400
    avatar = new Avatar
      model: player

    @notifier.connect(player)
    @notifier.getRoomPlayers()

    avatar.trailblazer = new Trailblazer
      player: player
      avatar: avatar
      canvas: @canvas

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition

    @mapView.spawnPlayer(player, avatar)

  addPlayer: (uuid, data) ->
    if data
      x_position = data.x_position
      y_position = data.y_position
    else
      x_position = 0
      y_position = 0

    player = new Player
      id: 1
      name: uuid
      x_position: x_position
      y_position: y_position
    avatar = new Avatar
      model: player

    avatar.trailblazer = new Trailblazer
      player: player
      avatar: avatar
      canvas: @canvas

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition
    @mapView.spawnPlayer(player, avatar)