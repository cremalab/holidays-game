Collection  = require './collection'

module.exports = class Players extends Collection
  initialize: ->
    super
    @subscribeEvent "players:left", (m) =>
      @remove(m)