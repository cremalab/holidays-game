View     = require 'views/view'
mediator = require 'lib/mediator'
template = require './templates/modal'

module.exports = class ModalView extends View
  template: template
  className: 'modal'
  initialize: (options) ->
    if options and options.template
      @template = options.template
    super
  render: ->
    super
    mediator.game_state = 'modal'
    unless @noClose
      @closeButton = document.createElement 'a'
      @el.querySelector('.modal-content-box').appendChild(@closeButton)
      @closeButton.setAttribute('href', '#')
      @closeButton.className = 'close icon-close'
      @closeButton.addEventListener 'click', (e) =>
        e.preventDefault()
        @dispose()

      window.addEventListener 'keyup', @checkEsc
        

  checkEsc: (e) =>
    if e.keyCode is 27
      e.stopPropagation()
      return @dispose()

  dispose: ->
    mediator.game_state = 'playing'
    window.removeEventListener 'keyup', @checkEsc
    super