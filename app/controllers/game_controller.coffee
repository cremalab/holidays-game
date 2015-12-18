MapView        = require 'views/map_view'
DJView         = require 'views/dj_view'
mediator       = require 'lib/mediator'
EventBroker    = require 'lib/event_broker'
Player         = require 'models/player'
Players        = require 'models/players'
PlayerList     = require 'views/player_list'
Avatar         = require 'views/avatar'
DrawingCanvas  = require 'views/drawing_canvas'
IntroView      = require 'views/intro_view'
Trailblazer    = require 'models/trailblazer'
Weather        = require 'lib/weather'
Notifier       = require 'models/notifier'
JoinGameView   = require 'views/join_game_view'
EditAvatarView = require 'views/edit_avatar_view'
AutoPilot      = require 'lib/autopilot'
Navi           = require 'lib/navi'
Reactor        = require 'lib/reactor'
Admin          = require 'lib/admin'
Whiteboard     = require 'models/whiteboard'
utils          = require 'lib/utils'

module.exports = class GameController
  Backbone.utils.extend @prototype, EventBroker
  players: []
  multiplayer: true
  snow: false
  trails: false
  customNames: true
  clickToNavigate: false

  constructor: ->
    @players = new Players []
    @whiteboard = mediator.whiteboard = new Whiteboard
      plots: []
    @setupDJ()
    @setupMap()
    @setupCanvas()
    @setupPlayer()
    if @multiplayer
      @notifier.connect mediator.current_player, "eastside", (channel) =>
        channel = channel.split("players_")[1]
        @mapView.setDimensions()
    @setupSidebar()
    @setupGameMenu()
    @admin = new Admin

    @subscribeEvent 'addPlayer', @addPlayer
    @subscribeEvent 'map:load', @loadMap
    @subscribeEvent 'triggerIntro', @intro
    @subscribeEvent 'togglePlayback', ->
      @DJ.togglePlayback()
    @createPlayerList()
    mediator.game_state = 'playing'
    window.loadMap = @loadMap.bind(@)


  setupMap: (mapOptions = {}) ->
    template = mapOptions.template or require('views/templates/eastside')
    @mapView = new MapView
      className: 'map'
      el: document.getElementById("map")
      autoRender: true
      template: template
      landscape: mapOptions.landscape
    @mapView.DJ = @DJ
    mediator = mediator

    @reactor = new Reactor(@mapView, @players)
    @nav     = new Navi(@mapView)

    Weather.snow('snowCanvas') if @snow

  setupDJ: ->
    @DJ = new DJView

  setupCanvas: ->
    @canvas = new DrawingCanvas
      el: document.getElementById('drawCanvas')
      autoRender: true

  setupPlayer: (options = {}) ->
    @notifier.dispose() if @notifier
    @notifier = mediator.notifier = new Notifier
    attrs = JSON.parse(localStorage.getItem("CremalabPartyAvatar"))
    mediator.current_player = new Player(attrs)
    mediator.current_player.set
      orientation: 1
      x_position: 968
      y_position: 1384
      active: true
      id: Date.now()
    view = @intro() unless options.skip_intro
    if view
      @mapView.listenTo view, 'dispose', =>
        @drawOrPromptAvatar()


  drawOrPromptAvatar: (options) ->
    if mediator.current_player.get('name')
      return @createPlayerAvatar(mediator.current_player, options)
    else
      if @customNames
        @promptPlayerName()
      else
        @createPlayerAvatar(mediator.current_player, options)

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


  createPlayerAvatar: (player, options = {}) ->
    player.set('moving', false)
    player.set('x_position', options.spawnX) if options.spawnX
    player.set('y_position', options.spawnY) if options.spawnY

    @currentAvatar.dispose() if @currentAvatar
    @currentAvatar = new Avatar
      model: player

    @currentAvatar.autopilot = new AutoPilot(@currentAvatar, @mapView)

    if @trails
      @currentAvatar.trailblazer = new Trailblazer
        player: player
        avatar: @currentAvatar
        canvas: @canvas

    @mapView.spawnPlayer(player, @currentAvatar)
    @mapView.listenTo @currentAvatar, 'playerMove', @mapView.checkPlayerPosition
    @mapView.addTouchEvents(@currentAvatar, 'touchstart')

    if @clickToNavigate
      @mapView.addTouchEvents(@currentAvatar, 'click')
    @mapView.centerMapOn(player.get('x_position'), player.get('y_position'), 0, 20)

  addPlayer: (uuid, data) ->
    if data
      unless parseFloat(uuid) is parseFloat(mediator.current_player.id)
        unless @players.get(uuid)
          player = new Player({id: uuid})
          player.set(data)
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
      map: @mapView

  setupGameMenu: ->
    editAvatarButton = document.createElement("button")
    document.getElementById('game-settings').appendChild(editAvatarButton)
    editAvatarButton.innerHTML = "Edit"
    editAvatarButton.addEventListener 'click', (e) =>
      e.preventDefault()
      @promptPlayerName(true)

  loadMap: (mapOptions) ->
    mediator.current_player.leaveRoom() if mediator.current_player
    @players.reset()
    @mapView.dispose() if @mapView
    newMap = document.createElement("div")
    newMap.id = "map"
    document.querySelector(".app-map").appendChild(newMap)

    @setupMap(mapOptions)
    @setupPlayer({skip_intro: true})
    @drawOrPromptAvatar(mapOptions)
    @mapView.setDimensions()

    mapName = mapOptions.name or "eastside"

    if @multiplayer
      @notifier.connect mediator.current_player, mapName, (channel) =>
        channel = channel.split("players_")[1]

  intro: (triggerVolume) ->
    view = new IntroView
      container: document.body
      triggerVolume: triggerVolume
    return view

  setupSidebar: ->
    logo = document.querySelector('.sidebar-brand')
    logo.addEventListener 'click', =>
      @publishEvent('triggerIntro', false)

    audioToggle = document.querySelector('.audioToggle')
    audioToggle.addEventListener 'click', =>
      @publishEvent('togglePlayback')
      audioToggle.classList.toggle('sub-muted')
