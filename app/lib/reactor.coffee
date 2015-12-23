EventBroker = require 'lib/event_broker'
mediator    = require 'lib/mediator'
actions     = require 'lib/actions'

module.exports = class Reactor
  Backbone.utils.extend @prototype, EventBroker
  constructor: (mapView, players) ->
    @map     = mapView
    @players = players
    @actions = actions
    console.log @actions
    @subscribeEvent 'reactor:act', @applyAction

  applyAction: (actionName, options...) ->
    @actions[actionName](@map, options)

  dispose: ->
    console.log 'dispose'
    @map     = null
    @players = null
    @actions = null
    @unsubscribeEvent 'reactor:act', @applyAction
