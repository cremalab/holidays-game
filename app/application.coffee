GameController = require 'controllers/game_controller'
mediator       = require 'lib/mediator'

# The application bootstrapper.
Application =
  initialize: ->    
    @gameController = new GameController()

    # Prevents scrolling on touch devices
    document.ontouchmove = (event) ->
      event.preventDefault()
      return

    # Freeze the object
    Object.freeze? this

module.exports = Application
