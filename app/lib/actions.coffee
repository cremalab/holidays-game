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