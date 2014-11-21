Model = require 'models/model'

module.exports = class Notifier extends Model
  connect: (player) ->
    @player = player

    @PN = PUBNUB.init
      publish_key: 'pub-c-7f96182e-eed7-46dd-9b72-80d838427d8e',
      subscribe_key: 'sub-c-b9f703c2-7109-11e4-aacc-02ee2ddab7fe'
      uuid: player.get('name')
      heartbeat: 10
    console.log 'connect'
    @subscribe()

  subscribe: ->
    @PN.subscribe
      channel: 'players'
      presence: (m) =>
        console.log 'presence!'
        @handlePresence(m)
      message: @message
      state:
        x_position: @player.get('x_position')
        y_position: @player.get('y_position')
    console.log 'subscribe'

  getRoomPlayers: ->
    @PN.here_now
      channel : 'players',
      callback: (message) =>
        @handlePlayers(message)

  message: (m) ->
    console.log m

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