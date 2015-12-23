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
    y: 700
    x: 1320
    proximity:
      radius: 100
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "Welcome to Crema!"
          id: "laura_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "laura_talk"
  ,
    id: "eric"
    src: "images/staff/eric.svg"
    y: 400
    x: 1750
    proximity:
      radius: 50
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "Go Royals!"
          id: "eric_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "eric_talk"
  ,
    id: "scotty"
    src: "images/staff/scotty.svg"
    y: 534
    x: 594
    proximity:
      radius: 60
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "'bout to make some pour-over coffee if you want some!"
          id: "scotty_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "scotty_talk"
  ,
    id: "george"
    src: "images/staff/george.svg"
    y: 270
    x: 580
    proximity:
      radius: 60
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "At Crema we’re dedicated to building solutions that solve problems and better lives"
          id: "george_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "george_talk"
  ,
    id: "dan"
    src: "images/dan.svg"
    x: 880
    y: 70
    proximity:
      radius: 60
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "Why hello, what would you say you do here?"
          id: "dan_talk"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "dan_talk"
  ,
    id: "deric"
    src: "images/staff/deric.svg"
    x: 1250
    y: 1300
  ,
    id: "matt-c"
    src: "images/staff/matt-c.svg"
    x: 1000
    y: 1300
  ,
    id: "kaley"
    src: "images/staff/kaley.svg"
    x: 360
    y: 1106
  ,
    id: "luke"
    src: "images/staff/luke.svg"
    x: 230
    y: 1206
  ,
    id: "carla_present"
    src: "images/present_2.svg"
    x: 360
    y: 1206
  ,
    id: "mitch"
    src: "images/staff/mitch.svg"
    x: 370
    y: 700
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
    width: 548
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
    id: "table_present"
    src: "images/present_3.png"
    x: 1260
    y: 320
  ,
    id: "table_plant"
    src: "images/plant.svg"
    x: 1420
    y: 300
  ,
    id: "golden_beaker"
    src: "images/westside/golden-beaker.svg"
    x: 1108
    y: 640
    zIndex: 680
    proximity:
      radius: 60
      onEnter: (item, options) ->
        hint =
          obstruction: item
          text: "[interact] Watch our '25 under 25' award video!"
          id: "gold_beaker"
        EventBroker.publishEvent 'navi:hint', hint
      onLeave: ->
        EventBroker.publishEvent 'navi:dismiss_hint', "gold_beaker"
      keys:
        action: ->
          EventBroker.publishEvent 'reactor:act', 'watch_award_video'
  ,
    id: "eric_table_present"
    src: "images/present_31.svg"
    y: 490
    x: 1770
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
    id: "automan1"
    src: "images/orange_chair.svg"
    x: 1105
    y: 980
  ,
    id: "automan2"
    src: "images/red_chair.svg"
    x: 1305
    y: 1000
  ,
    id: "couch2"
    src: "images/couch_flip.svg"
    x: 1905
    y: 1000
  ,
    id: "couch3"
    src: "images/couch_flip.svg"
    x: 1905
    y: 1200
  ,
    id: "office_chair1"
    src: "images/office_chair_flip.svg"
    x: 920
    y: 1200
  ,
    id: "office_chair2"
    src: "images/desk_chair.svg"
    x: 1470
    y: 1260
  ,
    id: "office_chair3"
    src: "images/desk_chair.svg"
    x: 530
    y: 1190
  ,
    id: "office_chair4"
    src: "images/desk_chair.svg"
    x: 230
    y: 1190
    mirror: true
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
    id: "tree"
    src: "images/tree2.svg"
    y: 45
    x: 1520
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
    id: "mac_flip1"
    src: "images/mac_flip.svg"
    x: 1300
    y: 1190
    ghosty: true
  ,
    id: "mac_flip2"
    src: "images/mac_flip.svg"
    x: 1070
    y: 1190
    ghosty: true
  ,
    id: "mac1"
    src: "images/mac.svg"
    x: 1300
    y: 1270
    ghosty: true
  ,
    id: "mac2"
    src: "images/mac.svg"
    x: 1070
    y: 1270
    ghosty: true
  ,
    id: "table2"
    src: "images/table.svg"
    y: 1180
    x: 280
  ,
    id: "table3"
    src: "images/table.svg"
    y: 1180
    x: 980
  ,
    id: "table4"
    src: "images/table.svg"
    y: 1255
    x: 1220
  ,
    id: "table5"
    src: "images/table.svg"
    y: 1255
    x: 980
  ,
    id: "present1"
    src: "images/present_31.png"
    x: 1345
    y: 1210
  ,
    id: "present2"
    src: "images/present_22.png"
    x: 485
    y: 595
  ,
    id: "present3"
    src: "images/present_35.png"
    x: 1405
    y: 705
  ,
    id: "present4"
    src: "images/present_32.png"
    x: 1215
    y: 675
]
