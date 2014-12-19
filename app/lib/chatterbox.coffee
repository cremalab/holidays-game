Model            = require 'models/model'
ChatInputView    = require 'views/chat_input_view'
ChatMessage      = require 'models/chat_message'
SpeechBubbleView = require 'views/speech_bubble_view'
mediator         = require 'lib/mediator'

module.exports = class ChatterBox extends Model
  initialize: ->
    super
    unless @get('avatar').soulless
      @subscribeEvent "messages:received:#{@get('player').id}", @renderSpeechBubble
    @subscribeEvent "messages:dismissed:#{@get('player').id}", @disposeBubble
    @current_player_name = mediator.current_player.get('name').toLowerCase()

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
      avatar: @get('avatar')

  submit: ->
    message = @dialog.el.querySelector("[name='chat_text']").value
    if message is "/admin"
      @publishEvent "admin:init"
      @open = false
      return @dialog.dispose()
    @open = false
    if message
      @message.set
        content: message
      @message.save()
      @renderSpeechBubble(@message)
    @dialog.dispose()

  renderSpeechBubble: (message) ->
    unless message instanceof ChatMessage
      message = new ChatMessage(message)
    @speechBubble.dispose() if @speechBubble
    @speechBubble = new SpeechBubbleView
      container: @get('avatar').el
      autoRender: true
      avatar: @get('avatar')
      model: message
      chatterBox: @
    @message = message

  mentionsCurrentPlayer: (message) ->
    pattern = /\B@[a-z0-9_-]+/g
    usernames = message.content.match pattern
    if usernames
      for username in usernames
        if username.replace('@', '').toLowerCase() is @current_player_name
          return true         

  disposeBubble: (local) ->
    @open = false
    @message.dispose() if @message
    @dialog.dispose() if @dialog
    @speechBubble.dispose() if @speechBubble
    if local
      @publishEvent "messages:dismissed", @get('player').id

