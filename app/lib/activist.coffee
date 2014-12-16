EventBroker = require 'lib/event_broker'

module.exports = class Activist
  Backbone.utils.extend @prototype, EventBroker
  actionKey: 32
  actionableItems: []
  constructor: (landscaper) ->
    @landscaper = landscaper
    document.addEventListener 'keydown', @handleKeyDown
    @subscribeEvent 'map:interact', @handleTap
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
    item.addEventListener 'enterProximity', (options) ->
      item.current_player_within_proximity = true
      item.proximity.onEnter(item, options) if item.proximity
    item.addEventListener 'leaveProximity', (options) ->
      item.current_player_within_proximity = false
      item.proximity.onLeave(item, options) if item.proximity
    if item.proximity and item.proximity.keys
      if item.proximity.keys.action
        @actionableItems.push item

  handleKeyDown: (e) =>
    switch e.keyCode
      when 32
        @fireActionHandlers()

  handleTap: (e, x, y) ->
    for item in @actionableItems
      if item.current_player_within_proximity
        av_proxy = 
          width: 10
          height: 10
        if @landscaper.avatarOverlaps(av_proxy, item, x - @landscaper.map.offset_x, y - @landscaper.map.offset_y)
          e.preventDefault()
          e.stopPropagation()
          item.proximity.keys.action(item)
          return false
        else 
          return e
      else
        return e

  fireActionHandlers: ->
    for item in @actionableItems
      if item.current_player_within_proximity
        item.proximity.keys.action(item)


