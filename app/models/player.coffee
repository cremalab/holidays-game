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
    parseInt(mediator.current_player.id) is parseInt(@id)

  setPosition: (data) ->
    unless @isCurrentPlayer()
      @set data

  streamPosition: ->
    @movement_inc++
    triggerMove = @movement_inc is 5 or 
      @hasChanged('orientation') or 
      @hasChanged('moving')
    if triggerMove
      @movement_inc = 0
      @publishEvent 'playerMoved', @ if @isCurrentPlayer()
      @set('z-plane', @get('y_position'))

  leaveRoom: ->
    @publishEvent 'players:left', @id

  handleLeave: (id) ->
    if id is @id
      @dispose()

  publishNameChange: ->
    @publishEvent 'players:name_changed', @ if @isCurrentPlayer()
    @save()

  save: ->
    if @isCurrentPlayer()
      attrs = @toJSON()
      delete attrs.id
      delete attrs.active
      localStorage.setItem "CremalabPartyAvatar", JSON.stringify(@toJSON())
      @publishEvent "players:avatar_changed", @
      return @

  dispose: ->
    @trigger 'dispose'
    super