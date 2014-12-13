# "Hey, listen!"
# Adds hints and tooltips to map on events

EventBroker = require 'lib/event_broker'
Hint        = require 'models/hint'
HintView    = require 'views/hint_view'

module.exports = class Navi
  Backbone.utils.extend @prototype, EventBroker
  subviews: []
  hints: []

  constructor: (map) ->
    @map = map
    @subscribeEvent "navi:hint", @hint
    @subscribeEvent "navi:dismiss_hint", @removeHint

  hint: (options) ->
    hint = new Hint options
    @hints.push hint
    view = new HintView
      model: hint
      container: @map.el
      autoRender: true
    @subviews.push view

  removeHint: (id) ->
    match = @hints.filter (item) ->
      item.id is id
    console.log match
    match = match[0]
    if match
      console.log match
      match.dispose()
      @hints.splice(@hints.indexOf(match), 1)
      @subviews.splice(@hints.indexOf(match), 1)



