Model            = require 'models/model'
ChatInputView    = require 'views/chat_input_view'
ChatMessage      = require 'models/chat_message'
SpeechBubbleView = require 'views/speech_bubble_view'
mediator         = require 'lib/mediator'

module.exports = class ChatterBox extends Model
  initialize: ->
    super
    @listenTo @get('player'), 'messages:draft', @draftMessage
    @subscribeEvent "messages:received:#{@get('player').id}", @checkMessageContent
    @subscribeEvent "messages:dismissed:#{@get('player').id}", @disposeBubble

  handleEnter: ->
    if @open
      @submit()
    else
      @openDialog()

  openDialog: (content) ->
    @speechBubble.dispose() if @speechBubble
    @open = true
    @message = new ChatMessage
      uuid: @get('player').id
      content: content
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

  checkMessageContent: (message) ->
    if @get('avatar').soulless
      if @mentionsCurrentPlayer(message)
        @renderSpeechBubble(message)
      else
        @disposeBubble()
    else
      @renderSpeechBubble(message)

  draftMessage: (message) ->
    unless @get('avatar').soulless
      @openDialog(message)

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
    usernames = message.content.toLowerCase().match pattern
    current_name = mediator.current_player.get('name').toLowerCase()
    if usernames
      if usernames.indexOf("@everyone") > -1 or usernames.indexOf("@all")
        return true
      for username in usernames
        if username.replace('@', '').toLowerCase() is current_name
          return true         

  disposeBubble: (local) ->
    @open = false
    @message.dispose() if @message
    @dialog.dispose() if @dialog
    @speechBubble.dispose() if @speechBubble
    if local
      @publishEvent "messages:dismissed", @get('player').id

