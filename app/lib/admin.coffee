mediator    = require 'lib/mediator'
EventBroker = require 'lib/event_broker'

module.exports = class Admin
  Backbone.utils.extend @prototype, EventBroker
  constructor: ->
    @subscribeEvent "admin:init", @init

  init: ->
    mediator.game_state = 'admin'
    @subscribeEvent "clickAvatar", @kickPlayer
    document.body.classList.add "admin"

  kickPlayer: (avatar, player, e) ->
    kick = confirm "Kick #{player.get('name')}?"
    if kick
      @publishEvent "admin:kick", player.id

  uninit: ->
    mediator.game_state = 'playing'
    @unsubscribeEvent "clickAvatar", @kickPlayer
    document.body.classList.remove "admin"