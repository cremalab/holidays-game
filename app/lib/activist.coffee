EventBroker = require 'lib/event_broker'

module.exports = class Activist
  Backbone.utils.extend @prototype, EventBroker

  activate: (ob) ->
    ob.onHit = ob.onHit or {}
    ob.events = {}
    ob.addEventListener = (eventName, handler) ->
      @events[eventName] = [] if !@events[eventName]
      @events[eventName].push handler
      return

    ob.raiseEvent = (eventName, args) ->
      currentEvents = @events[eventName]
      return  unless currentEvents
      i = 0

      while i < currentEvents.length
        currentEvents[i] args  if typeof currentEvents[i] is "function"
        i++
      return
    @addActor(ob)
    return ob

  addActor: (item) ->
    item.addEventListener 'hit_left', (options) ->
      item.onHit.left(item, options) if item.onHit.left
    item.addEventListener 'hit_right', (options) ->
      item.onHit.right(item, options) if item.onHit.right
    item.addEventListener 'hit_top', (options) ->
      item.onHit.top(item, options) if item.onHit.top
    item.addEventListener 'hit_bottom', (options) ->
      item.onHit.bottom(item, options) if item.onHit.bottom
    item.addEventListener 'hit_any', (options) ->
      item.onHit.any(item, options) if item.onHit.any

