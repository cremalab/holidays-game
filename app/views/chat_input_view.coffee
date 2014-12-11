View     = require 'views/view'
template = require './templates/chat_input'

module.exports = class ChatInputView extends View
  template: template
  className: 'chat-dialog speech-bubble'
  render: ->
    super
    @el.querySelector('input').addEventListener 'blur', ->
      window.scrollTo(0, 0)