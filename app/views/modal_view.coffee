View     = require 'views/view'
mediator = require 'lib/mediator'
template = require './templates/modal'

module.exports = class ModalView extends View
  template: template
  className: 'modal'
  initialize: ->
    super
  render: ->
    super
    mediator.game_state = 'modal'
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