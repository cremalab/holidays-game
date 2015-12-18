EventBroker = require 'lib/event_broker'

module.exports = [
  id: "es-door"
  src: "images/john.png"
  x: 20
  y: 500
  proximity:
    radius: 20
    onEnter: (item, options) ->
      mapOptions =
        template: require('views/templates/eastside')
        landscape: require('config/maps/eastside')
        name: "eastside"
        spawnX: 1900
        spawnY: 520
      EventBroker.publishEvent 'map:load', mapOptions
    onLeave: ->
      # 
]
