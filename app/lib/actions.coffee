Modal    = require 'views/modal_view'
mediator = require 'lib/mediator'

module.exports = 
  team_photo: (map) ->
    unless mediator.game_state is 'modal'
      view = new Modal
        container: document.body
        className: 'modal'
        template: require 'views/templates/team_photo'
        autoRender: true
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
