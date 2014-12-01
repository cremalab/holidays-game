View     = require 'views/view'
template = require './templates/chat_input'

module.exports = class ChatInputView extends View
  template: template
  className: 'chat-dialog speech-bubble'