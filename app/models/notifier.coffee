mediator = require 'lib/mediator'
Model    = require 'models/model'
Escort   = require 'lib/escort'

module.exports = class Notifier extends Model
  connect: (player, onConnect) ->
    @player = player
    @PN = PUBNUB.init
      # Be cool with these keys, developer dudes
      publish_key: 'pub-c-7f96182e-eed7-46dd-9b72-80d838427d8e',
      subscribe_key: 'sub-c-b9f703c2-7109-11e4-aacc-02ee2ddab7fe'
      uuid: player.get('id')
      heartbeat: 10
      restore: true

    Escort.findEmptyRoom @PN, (channel_name) =>
      @subscribe(channel_name, onConnect)
      @subscribeEvent 'playerMoved', @publishPlayerMovement
      @subscribeEvent "players:left", @removePlayer
      @subscribeEvent "messages:saved", @publishMessage
      @subscribeEvent "messages:dismissed", @dismissMessage
      @subscribeEvent "players:name_changed", @setAttrs
      @subscribeEvent "players:avatar_changed", @setAttrs

      pubnub = @PN

      window.addEventListener "beforeunload", (e) =>
        @PN.unsubscribe
          channel: @channel

  subscribe: (channel, onConnect) ->
    attrs = @player.toJSON()
    delete attrs.active
    @PN.subscribe
      channel: channel
      presence: (m) =>
        @handlePresence(m)
      message: (m) =>
        @message(m)
      state: attrs
      connect: =>
        @channel = channel
        @getRoomPlayers(onConnect)

  getRoomPlayers: (onConnect) ->
    @PN.here_now
      channel : @channel
      state: true
      callback: (message) =>
        @handlePlayers(message, onConnect)

  message: (m) ->
    if m.type
      switch m.type
        when 'chat_message'
          unless mediator.current_player.id is m.uuid
            @publishEvent "messages:received:#{m.uuid}", m
        when 'chat_message_dismissed'
          @publishEvent "messages:dismissed:#{m.uuid}"

  handlePlayers: (message, onConnect) ->
    if message.uuids
      for player in message.uuids
        unless parseInt(player.uuid) is parseInt(@player.get('id'))
          @publishEvent 'addPlayer', player.uuid, player.state
    
    onConnect(@channel) if onConnect

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
    moving      = player.get('moving')
    @setAttrs(player)

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

  setAttrs: (player) ->
    attrs = player.toJSON()
    delete attrs.active
    @PN.state
      channel  : @channel
      state    : attrs