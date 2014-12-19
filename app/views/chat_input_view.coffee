View     = require 'views/view'
template = require './templates/chat_input'

module.exports = class ChatInputView extends View
  template: template
  className: 'chat-dialog speech-bubble'
  render: ->
    super
    @input = @el.querySelector('input')
    if @model.get('content')
      @input.addEventListener 'focus', =>
        @input.value = @model.get('content')
    setTimeout =>
      @input.focus()
    , 0
    @input.addEventListener 'blur', ->
      window.scrollTo(0, 0)
