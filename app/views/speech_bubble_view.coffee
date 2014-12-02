View = require 'views/view'
template = require './templates/speech_bubble'

module.exports = class SpeechBubbleView extends View
  className: "speech-bubble"
  template: template

  initialize: (options) ->
    super
    @avatar = options.avatar

  render: ->
    super
    setTimeout =>
      @rect = @el.getClientRects()[0]
      @el.style.top = "#{-(@rect.height + 20)}px"
      @el.style.left = "#{-(@rect.width / 4)}px"
    , 0