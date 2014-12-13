EventBroker = require 'lib/event_broker'
mediator    = require 'lib/mediator'
actions     = require 'lib/actions'

module.exports = class Reactor
  Backbone.utils.extend @prototype, EventBroker
  constructor: (mapView, players) ->
    @map     = mapView
    @players = players
    @actions = actions
    @subscribeEvent 'reactor:act', (actionName) =>
      @actions[actionName](@map)



