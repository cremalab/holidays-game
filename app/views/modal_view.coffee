View     = require 'views/view'
mediator = require 'lib/mediator'

module.exports = class ModalView extends View
  initialize: (options) ->
    if options and options.template
      @template = options.template
    super
  render: ->
    super
    unless @noClose
      @closeButton = document.createElement 'a'
      @closeButton.innerHTML = "&times;"
      @el.querySelector('.modal-content-box').appendChild(@closeButton)
      @closeButton.setAttribute('href', '#')
      @closeButton.className = 'close'
      @closeButton.addEventListener 'click', =>
        @dispose()

      window.addEventListener 'keyup', (e) =>
        if e.keyCode is 27
          return @dispose()

  dispose: ->
    mediator.game_state = 'playing'
    super