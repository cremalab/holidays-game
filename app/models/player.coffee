mediator = require 'lib/mediator'
Model = require 'models/model'

module.exports = class Player extends Model
  movement_inc: 0
  defaults:
    x_position: 0
    y_position: 0

  initialize: ->
    super
    @listenTo @, "change:x_position change:y_position", @streamPosition
    @subscribeEvent "players:moved:#{@id}", @setPosition

  position: ->
    return "#{@get('x_position')}px, #{@get('y_position')}px"

  isCurrentPlayer: ->
    mediator.current_player.id is @id

  setPosition: (data) ->
    console.log @isCurrentPlayer()
    unless @isCurrentPlayer()
      @set
        x_position: data.x_position
        y_position: data.y_position

  streamPosition: ->
    @movement_inc++
    if @movement_inc is 10
      @movement_inc = 0
      @publishEvent 'playerMoved', @ if @isCurrentPlayer()