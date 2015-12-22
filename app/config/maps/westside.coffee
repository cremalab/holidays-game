EventBroker = require 'lib/event_broker'

module.exports = [
  id: "es-door"
  x: 0
  y: 340
  height: 200
  width: 20
  proximity:
    radius: 20
    onEnter: (item, options) ->
      mapOptions =
        template: require('views/templates/eastside')
        landscape: require('config/maps/eastside')
        name: "eastside"
        spawnX: 1900
        spawnY: 520
        orientation: 7
      EventBroker.publishEvent 'map:load', mapOptions
    onLeave: ->
      #
  ,
    id: "laura"
    src: "images/staff/laura.svg"
    x: 380
    y: 1070
    proximity:
      radius: 60
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "Hi."
          id: "laura_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "laura_talk"
  ,
    id: "carla_wall"
    src: "images/wall3.svg"
    x: 149
    y: 965
  ,
    id: "carla_lower_wall"
    src: "images/wall4.svg"
    x: 697
    y: 1290
  ,
    id: "behind_bar"
    x: 57
    y: 543
    width: 155
    height: 413
  ,
    id: "es_bathroom"
    x: 20
    y: 0
    width: 528
    height: 352
  ,
    id: "coffee_bar"
    src: "images/westside/coffee-bar.svg"
    x: 460
    y: 582
  ,
    id: "coffee_table"
    src: "images/westside/coffee-table.svg"
    x: 1160
    y: 280
  ,
    id: "couch"
    src: "images/westside/couch.svg"
    x: 1165
    y: 100
  ,
    id: "desk_wall"
    src: "images/westside/desk-wall.svg"
    x: 1005
    y: 840
  ,
    id: "receptionist_top"
    src: "images/westside/long-white-table-wide.svg"
    x: 1078
    y: 665
  ,
    id: "receptionist_right"
    x: 1377
    y: 665
    height: 180
    width: 80
    backgroundColor: "#fff"
  ,
    id: "standing_desk1"
    src: "images/westside/long-white-table-tall.svg"
    y: 95
    x: 957
  ,
    id: "standing_desk2"
    src: "images/westside/long-white-table-wide.svg"
    y: 190
    x: 538
  ,
    id: "standing_desk3"
    src: "images/westside/long-white-table-wide.svg"
    y: 190
    x: 1657
  ,
    id: "standing_desk4"
    src: "images/westside/long-white-table-wide.svg"
    y: 470
    x: 1657
  ,
    id: "table1"
    src: "images/table.svg"
    y: 1180
    x: 1220
  ,
    id: "table2"
    src: "images/table.svg"
    y: 1180
    x: 280
]
