View = require 'views/view'

module.exports = class ModalView extends View
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