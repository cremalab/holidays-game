Modal     = require './modal_view'
Avatar   = require 'views/avatar'
mediator = require 'lib/mediator'
template = require './templates/join_game'

module.exports = class JoinGameView extends Modal
  template: template
  autoRender: true
  tagName: 'form'
  noClose: true

  render: ->
    super
    radios = @el.querySelectorAll("input[type='radio']")
    checkboxes = @el.querySelectorAll("input[type='checkbox']")
    mediator.game_state = 'modal'

    @avatarView = new Avatar
      model: @model
      soulless: true
      container: @el.querySelector('.avatar-holder')
      autoRender: true

    for radio in radios
      radio.addEventListener 'change', (e) =>
        name = e.target.name
        val  = @el.querySelector("input[name='#{name}']:checked").value
        @model.set(name, val)

    for checkbox in checkboxes
      checkbox.addEventListener 'change', (e) =>
        name = e.target.name
        val  = e.target.id
        if e.target.checked
          @model.set(name, val)
        else
          @model.unset(name)

    @el.addEventListener 'submit', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @trigger('setPlayerName', document.getElementById('player_name').value)

  dispose: ->
    mediator.game_state = 'playing'
    @avatarView.dispose()
    super
