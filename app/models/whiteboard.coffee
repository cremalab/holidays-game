Model = require 'models/model'

module.exports = class Whiteboard extends Model
  initialize: ->
    super
    @subscribeEvent "whiteboard:draw", @setPlots

  setPlots: (m) ->
    # temp = @get('plots').concat(m.plots)
    @set 'plots', m.plots