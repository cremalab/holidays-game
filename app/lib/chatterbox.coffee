Model = require 'models/model'
ChatInputView = require 'views/chat_input_view'
ChatMessage = require 'models/chat_message'
SpeechBubbleView = require 'views/speech_bubble_view'

module.exports = class ChatterBox extends Model
  initialize: ->
    super
    @subscribeEvent "messages:received:#{@get('player').id}", @renderSpeechBubble
    @subscribeEvent "messages:dismissed:#{@get('player').id}", @disposeBubble

  handleEnter: ->
    if @open
      @submit()
    else
      @openDialog()

  openDialog: ->
    @speechBubble.dispose() if @speechBubble
    @open = true
    @message = new ChatMessage
      uuid: @get('player').id
    @dialog = new ChatInputView
      container: @get('avatar').el
      autoRender: true
      model: @message

  submit: ->
    @open = false
    @message.set
      content: @dialog.el.querySelector("[name='chat_text']").value
    @message.save()
    @dialog.dispose()
    @renderSpeechBubble(@message)

  renderSpeechBubble: (message) ->
    unless message instanceof ChatMessage
      message = new ChatMessage(message)
    @speechBubble.dispose() if @speechBubble
    @speechBubble = new SpeechBubbleView
      container: @get('avatar').el
      autoRender: true
      avatar: @get('avatar')
      model: message
    @message = message

  disposeBubble: (local) ->
    @open = false
    @message.dispose() if @message
    @dialog.dispose() if @dialog
    @speechBubble.dispose() if @speechBubble
    if local
      @publishEvent "messages:dismissed", @get('player').id

