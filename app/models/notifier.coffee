mediator = require 'lib/mediator'
Model    = require 'models/model'
Escort   = require 'lib/escort'

module.exports = class Notifier extends Model
  connect: (player, onConnect) ->
    @player = player

    @PN = PUBNUB.init
      publish_key: 'pub-c-7f96182e-eed7-46dd-9b72-80d838427d8e',
      subscribe_key: 'sub-c-b9f703c2-7109-11e4-aacc-02ee2ddab7fe'
      uuid: player.get('id')
      heartbeat: 10
      restore: true

    Escort.findEmptyRoom @PN, (channel_name) =>
      console.log channel_name
      @subscribe(channel_name, onConnect)
      @subscribeEvent 'playerMoved', @publishPlayerMovement
      @subscribeEvent "players:left", @removePlayer
      @subscribeEvent "messages:saved", @publishMessage
      @subscribeEvent "messages:dismissed", @dismissMessage
      @subscribeEvent "players:name_changed", @setName

      pubnub = @PN

      window.addEventListener "beforeunload", (e) =>
        @PN.unsubscribe
          channel: @channel

  subscribe: (channel, onConnect) ->
    console.log "subscribing to channel #{channel}"
    @PN.subscribe
      channel: channel
      presence: (m) =>
        @handlePresence(m)
      message: (m) =>
        @message(m)
      state:
        name: @player.get('name')
        x_position: @player.get('x_position')
        y_position: @player.get('y_position')
      connect: =>
        @channel = channel
        onConnect(channel) if onConnect
        @getRoomPlayers()

  getRoomPlayers: ->
    @PN.here_now
      channel : @channel
      state: true
      callback: (message) =>
        @handlePlayers(message)

  message: (m) ->
    if m.type
      switch m.type
        when 'chat_message'
          unless mediator.current_player.id is m.uuid
            @publishEvent "messages:received:#{m.uuid}", m
        when 'chat_message_dismissed'
          @publishEvent "messages:dismissed:#{m.uuid}"

  handlePlayers: (message) ->
    if message.uuids
      for player in message.uuids
        console.log player.uuid
        console.log player.state
        unless player.uuid is @player.get('id')
          @publishEvent 'addPlayer', player.uuid, player.state

  handlePresence: (m,a) ->
    unless m.uuid is mediator.current_player.id
      switch m.action
        when 'join'
          @publishEvent 'addPlayer', m.uuid, m.data
        when 'state-change'
          @publishEvent "players:moved:#{m.uuid}", m.data
        when 'leave'
          @publishEvent "players:left", m.uuid
        when 'timeout'
          @publishEvent "players:left", m.uuid

  publishPlayerMovement: (player) ->
    x_position  = player.get('x_position')
    y_position  = player.get('y_position')
    orientation = player.get('orientation')
    name        = player.get('name')

    @PN.state
      channel  : @channel,
      state    :
        x_position:  x_position
        y_position:  y_position
        orientation: orientation
        name:        name

  removePlayer: (id) ->
    if mediator.current_player.id is id
      console.log 'unsubscribe'
      @PN.unsubscribe
        channel: 'players'

  publishMessage: (attributes) ->
    attributes.type = 'chat_message'
    @PN.publish
      channel: @channel
      message: attributes

  dismissMessage: (uuid) ->
    @PN.publish
      channel: @channel
      message:
        type: 'chat_message_dismissed'
        uuid: uuid

  setName: (player) ->
    @PN.state
      channel  : @channel
      state    :
        name:  player.get('name')