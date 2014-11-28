mediator = require 'lib/mediator'
Model    = require 'models/model'

module.exports = class Notifier extends Model
  connect: (player) ->
    @player = player
    @PN = PUBNUB.init
      publish_key: 'pub-c-7f96182e-eed7-46dd-9b72-80d838427d8e',
      subscribe_key: 'sub-c-b9f703c2-7109-11e4-aacc-02ee2ddab7fe'
      uuid: player.get('id')
      heartbeat: 10
    console.log 'connect'
    @subscribe()
    @subscribeEvent 'playerMoved', @publishPlayerMovement
    @subscribeEvent "players:left", @removePlayer

    pubnub = @PN

    window.addEventListener "beforeunload", (e) =>
      @PN.unsubscribe
        channel: "players"

  subscribe: ->
    @PN.subscribe
      channel: 'players'
      presence: (m) =>
        @handlePresence(m)
      message: (m) =>
        @message(m)
      state:
        x_position: @player.get('x_position')
        y_position: @player.get('y_position')

  getRoomPlayers: (d) ->
    @PN.here_now
      channel : 'players'
      state: true
      callback: (message) =>
        console.log message
        @handlePlayers(message)

  message: (m) ->
    # if m.action and m.action is 'move'
    #   console.log "UUID: #{m.uuid}"
    #   unless mediator.current_player.id is m.uuid
    #     @publishEvent "players:moved:#{m.uuid}", m

  handlePlayers: (message) ->
    if message.uuids
      for player in message.uuids
        console.log player
        unless player.uuid is @player.get('id')
          @publishEvent 'addPlayer', player.uuid, player.state

  handlePresence: (m) ->
    unless m.uuid is mediator.current_player.id
      switch m.action
        when 'join'
          console.log 'join!'
          @publishEvent 'addPlayer', m.uuid, m.data
        when 'state-change'
          @publishEvent "players:moved:#{m.uuid}", m.data
        when 'leave'
          @publishEvent "players:left", m.uuid

  publishPlayerMovement: (player) ->
    x_position = player.get('x_position')
    y_position = player.get('y_position')
    direction  = player.get('position_direction')

    @PN.state
      channel  : "players",
      state    :
        x_position: x_position
        y_position: y_position
        direction: direction

  removePlayer: (id) ->
    if mediator.current_player.id is id
      console.log 'unsubscribe'
      @PN.unsubscribe
        channel: 'players'
