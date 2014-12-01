GameController = require 'controllers/game_controller'
mediator       = require 'lib/mediator'

# The application bootstrapper.
Application =
  initialize: ->    
    @gameController = new GameController()

    # Freeze the object
    Object.freeze? this

module.exports = Application
