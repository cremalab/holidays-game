MapView       = require 'views/map_view'
mediator      = require 'lib/mediator'
EventBroker   = require 'lib/event_broker'
Player        = require 'models/player'
Players       = require 'models/players'
PlayerList    = require 'views/player_list'
Avatar        = require 'views/avatar'
DrawingCanvas = require 'views/drawing_canvas'
Trailblazer   = require 'models/trailblazer'
Weather       = require 'lib/weather'
Notifier      = require 'models/notifier'
utils         = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  players: []

  constructor: ->
    @players = new Players []
    @notifier = new Notifier
    @setupMap()
    @setupCanvas()
    @createPlayer()
    @subscribeEvent 'addPlayer', @addPlayer
    @createPlayerList()

  setupMap: ->
    @mapView = new MapView
      className: 'map'
      el: document.getElementById("map")
      autoRender: true
    mediator = mediator
    document.getElementById('leave_room').addEventListener 'click', (e) =>
      e.preventDefault()
      mediator.current_player.leaveRoom()
    # Weather.snow('snowCanvas')

  setupCanvas: ->
    @canvas = new DrawingCanvas
      el: document.getElementById('drawCanvas')
      autoRender: true

  createPlayer: ->
    id = Date.now()
    player = new Player
      id: id
      name: id
      x_position: 400
      y_position: 2800
      active: true
    avatar = new Avatar
      model: player

    mediator.current_player = player

    @notifier.connect(player)
    # @notifier.getRoomPlayers()

    avatar.trailblazer = new Trailblazer
      player: player
      avatar: avatar
      canvas: @canvas

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition

    @mapView.spawnPlayer(player, avatar)
    @players.add player

  addPlayer: (uuid, data) ->
    # console.log uuid is mediator.current_player.id
    unless parseFloat(uuid) is parseFloat(mediator.current_player.id)
      console.log 'add new Player'
      if data
        x_position = data.x_position
        y_position = data.y_position
      else
        x_position = 400
        y_position = 1000

      player = new Player
        id: uuid
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
      @players.add player

  createPlayerList: ->
    list = new PlayerList
      collection: @players
      autoRender: true
      container: document.getElementById('player_list')