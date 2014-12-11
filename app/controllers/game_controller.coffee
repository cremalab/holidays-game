MapView        = require 'views/map_view'
mediator       = require 'lib/mediator'
EventBroker    = require 'lib/event_broker'
Player         = require 'models/player'
Players        = require 'models/players'
PlayerList     = require 'views/player_list'
Avatar         = require 'views/avatar'
DrawingCanvas  = require 'views/drawing_canvas'
Trailblazer    = require 'models/trailblazer'
Weather        = require 'lib/weather'
Notifier       = require 'models/notifier'
JoinGameView   = require 'views/join_game_view'
EditAvatarView = require 'views/edit_avatar_view'
AutoPilot      = require 'lib/autopilot'
utils          = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  players: []
  multiplayer: false
  snow: false
  trails: false
  customNames: true
  clickToNavigate: false

  constructor: ->
    @players = new Players []
    @notifier = new Notifier
    @setupMap()
    @setupCanvas()
    @setupPlayer()

    @subscribeEvent 'addPlayer', @addPlayer
    @createPlayerList()
    mediator.game_state = 'playing'

  setupMap: ->
    @mapView = new MapView
      className: 'map'
      el: document.getElementById("map")
      autoRender: true
    mediator = mediator

    Weather.snow('snowCanvas') if @snow

  setupCanvas: ->
    @canvas = new DrawingCanvas
      el: document.getElementById('drawCanvas')
      autoRender: true

  setupPlayer: ->
    mediator.current_player = new Player
      orientation: 1
    mediator.current_player.fetch()

    if mediator.current_player.id
      @createPlayerAvatar(mediator.current_player)
    else
      @createPlayer()
      if @customNames
        @promptPlayerName()
      else
        @createPlayerAvatar(mediator.current_player)

  promptPlayerName: (editing) ->
    player = mediator.current_player
    if editing
      view = new EditAvatarView
        container: document.body
        model: player
    else
      view = new JoinGameView
        container: document.body
        model: player

    mediator.current_player.listenTo view, 'setPlayerName', (name) =>
      view.dispose()
      player.set('name', name)
      player.save()
      @createPlayerAvatar(player) unless editing

  createPlayer: ->
    id = Date.now()
    player = mediator.current_player = new Player
      id: id
      name: id
      x_position: 600
      y_position: 200
      active: true
      orientation: 1

    player.save()

    if @multiplayer
      @notifier.connect player, (channel) =>
        channel = channel.split("players_")[1]
        document.getElementById("room_name").innerHTML = channel


  createPlayerAvatar: (player) ->
    avatar = new Avatar
      model: player
    avatar.autopilot = new AutoPilot(avatar, @mapView)

    if @trails
      avatar.trailblazer = new Trailblazer
        player: player
        avatar: avatar
        canvas: @canvas

    @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition

    @mapView.spawnPlayer(player, avatar)
    @players.add player
    @mapView.addTouchEvents(avatar, 'touchstart')

    if @clickToNavigate
      @mapView.addTouchEvents(avatar, 'click')
    @setupGameMenu()

  addPlayer: (uuid, data) ->
    unless parseFloat(uuid) is parseFloat(mediator.current_player.id)
      if data
        x_position = data.x_position
        y_position = data.y_position
        name = data.name
      else
        x_position = 400
        y_position = 1000
        name = uuid
      player = new Player
        id: uuid
        name: name
        x_position: x_position
        y_position: y_position
      avatar = new Avatar
        model: player

      if @trails
        avatar.trailblazer = new Trailblazer
          player: player
          avatar: avatar
          canvas: @canvas

      @mapView.listenTo avatar, 'playerMove', @mapView.checkPlayerPosition
      @mapView.spawnPlayer(player, avatar)
      @players.add player

  createPlayerList: ->
    @playerList = new PlayerList
      collection: @players
      autoRender: true
      container: document.getElementById('player_list')

  setupGameMenu: ->
    editAvatarButton = document.createElement("button")
    document.getElementById('game-settings').appendChild(editAvatarButton)
    editAvatarButton.innerHTML = "Edit my Avatar"
    editAvatarButton.addEventListener 'click', (e) =>
      e.preventDefault()
      @promptPlayerName(true)
