View       = require './view'

module.exports = class Snowball extends View
  template: '<div></div>'
  autoRender: false
  className: 'snowball'

  initialize: (defaults) ->
    @position = defaults.position

  render: () ->
    #@el.parentNode.insertBefore(snowball, @el.nextSibling)
    console.log(@position.orientation)
    @el.style.left = @position.x + 'px'
    @el.style.top = @position.y + 'px'
    @container.appendChild(@el)

    setTimeout(() =>
      @container.removeChild(@el)
    , 2000)
