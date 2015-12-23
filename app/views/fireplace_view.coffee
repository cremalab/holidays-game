View     = require 'views/view'
mediator = require 'lib/mediator'

module.exports = class FireplaceView extends View
  tagName: 'div'
  className: 'obstruction fireplace'
  stepLength: 2
  step: 1
  render: ->
    super
    @el.style.top = "910px"
    @el.style.left = "1185px"
    @el.style.width = "85px"
    @el.style.height = "20px"
    @el.style.zIndex = "910"
    @el.style.backgroundImage = "url('/images/westside/fire-one.svg')"

    @aniInterval = setInterval @stepFrames.bind(@), 300

  stepFrames: ->
    switch @step
      when 1
        @el.style.backgroundImage = "url('/images/westside/fire-two.svg')"
        @step = 2
      when 2
        @el.style.backgroundImage = "url('/images/westside/fire-one.svg')"
        @step = 1

  dispose: ->
    clearInterval @aniInterval
    super
