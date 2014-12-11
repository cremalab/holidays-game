View = require './view'
Avatar = require 'views/avatar'
template = require './templates/join_game'

module.exports = class JoinGameView extends View
  template: template
  autoRender: true
  className: 'modal'
  tagName: 'form'

  render: ->
    super
    radios = @el.querySelectorAll("input[type='radio']")

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

    @el.addEventListener 'submit', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @trigger('setPlayerName', document.getElementById('player_name').value)

  dispose: ->
    @avatarView.dispose()
    super
