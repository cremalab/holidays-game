mediator = require 'lib/mediator'
Model = require 'models/model'

module.exports = class Player extends Model
  movement_inc: 0
  defaults:
    x_position: 0
    y_position: 0

  initialize: ->
    super
    @listenTo @, "change:x_position change:y_position change:orientation change:moving", @streamPosition
    @listenTo @, "change:name", @publishNameChange
    @subscribeEvent "players:moved:#{@id}", @setPosition
    @subscribeEvent "players:left", @handleLeave

  position: ->
    return "#{@get('x_position')}px, #{@get('y_position')}px"

  isCurrentPlayer: ->
    mediator.current_player.id is @id

  setPosition: (data) ->
    unless @isCurrentPlayer()
      if data.x_position or data.orientation or data.moving
        @set
          x_position: data.x_position
          y_position: data.y_position
          orientation: data.orientation
          moving: data.moving
      if data.name
        @set 'name', data.name

  streamPosition: ->
    @movement_inc++
    triggerMove = @movement_inc is 6 or 
      @hasChanged('orientation') or 
      @hasChanged('moving')
    if triggerMove
      @movement_inc = 0
      @publishEvent 'playerMoved', @ if @isCurrentPlayer()

  leaveRoom: ->
    @publishEvent 'players:left', @id

  handleLeave: (id) ->
    if id is @id
      @dispose()

  publishNameChange: ->
    @publishEvent 'players:name_changed', @ if @isCurrentPlayer()
    @save()

  save: ->
    localStorage.setItem "CremalabPartyAvatar", JSON.stringify(@toJSON())
    return @

  fetch: ->
    @set JSON.parse(localStorage.getItem("CremalabPartyAvatar"))
    return @
