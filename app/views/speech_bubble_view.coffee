View     = require 'views/view'
template = require './templates/speech_bubble'

module.exports = class SpeechBubbleView extends View
  className: "speech-bubble"
  template: template

  initialize: (options) ->
    super
    @chatterBox = options.chatterBox
    @avatar     = options.avatar

  render: ->
    super
    if @avatar.model.isCurrentPlayer()
      @el.querySelector('.close').addEventListener 'click', (e) =>
        e.stopPropagation()
        e.preventDefault()
        @chatterBox.disposeBubble(true)
      @el.querySelector('.close').addEventListener 'touchstart', (e) =>
        e.stopPropagation()
        e.preventDefault()
        @chatterBox.disposeBubble(true)
    else
      @el.removeChild(@el.querySelector('.close'))