Modal       = require 'views/modal_view'
mediator    = require 'lib/mediator'
EventBroker = require 'lib/event_broker'

module.exports =
  team_photo: (map) ->
    unless mediator.game_state is 'modal'
      view = new Modal
        container: document.body
        className: 'modal'
        template: require 'views/templates/team_photo'
        autoRender: true
      mediator.game_state = 'modal'
  bathroom_photo: (map) ->
    unless mediator.game_state is 'modal'
      view = new Modal
        container: document.body
        className: 'modal'
        template: require 'views/templates/bathroom_photo'
        autoRender: true
    if @audio.paused
      mediator.game_state = 'modal'
  lamp_light: (map, options) ->
    item= options[0]
    if item.img
      if item.lamp_on
        item.img.setAttribute('src', '/images/Lamp_1.png')
        item.lamp_on = false
      else
        item.img.setAttribute('src', '/images/Lamp_2.png')
        item.lamp_on = true
  lamp_light_flip: (map, options) ->
    item= options[0]
    if item.img
      if item.lamp_on
        item.img.setAttribute('src', '/images/Lamp_1_flip.png')
        item.lamp_on = false
      else
        item.img.setAttribute('src', '/images/Lamp_2_flip.png')
        item.lamp_on = true
  tweet_friends: (map, options) ->
    window.open options[0], "twitter"

  disco: (map) ->
    console.log @
    classList = map.el.classList
    if classList.contains('disco-time')
      classList.remove 'disco-time'
      map.DJ.playTrack('soundtrack')
    else
      classList.add 'disco-time'
      map.DJ.playTrack('disco')
