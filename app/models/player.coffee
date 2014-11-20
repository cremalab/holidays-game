Model = require 'models/model'

module.exports = class Player extends Model
  defaults:
    x_position: 0
    y_position: 0

  position: ->
    return "#{@get('x_position')}px, #{@get('y_position')}px"