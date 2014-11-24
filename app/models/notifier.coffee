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

    window.addEventListener 'onbeforeunload', =>
      @PN.unsubscribe('players')

  subscribe: ->
    @PN.subscribe
      channel: 'players'
      presence: (m) =>
        console.log 'presence!'
        @handlePresence(m)
      message: (m) =>
        @message(m)
      state:
        x_position: @player.get('x_position')
        y_position: @player.get('y_position')

  getRoomPlayers: ->
    @PN.here_now
      channel : 'players'
      state: true
      callback: (message) =>
        @handlePlayers(message)

  message: (m) ->
    # if m.action and m.action is 'move'
    #   console.log "UUID: #{m.uuid}"
    #   unless mediator.current_player.id is m.uuid
    #     @publishEvent "players:moved:#{m.uuid}", m

  handlePlayers: (message) ->
    if message.uuids
      for player in message.uuids
        console.log @player.get('name') is player
        unless player is @player.get('name')
          @publishEvent 'addPlayer', player

  handlePresence: (m) ->
    console.log m
    switch m.action
      when 'join'
        console.log m.uuid
        @publishEvent 'addPlayer', m.uuid, m.data
      when 'state-change'
        console.log "player id: #{m.uuid}"
        @publishEvent "players:moved:#{m.uuid}", m.data

  publishPlayerMovement: (player) ->
    console.log 'publishPlayerMovement'
    x_position = player.get('x_position')
    y_position = player.get('y_position')

    # @PN.publish
    #   channel : "players"
    #   message:
    #     action: 'move'
    #     uuid: player.get('id')
    #     x_position: x_position
    #     y_position: y_position
    @PN.state
      channel  : "players",
      state    : 
        x_position: x_position
        y_position: y_position
