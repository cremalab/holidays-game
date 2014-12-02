View = require './view'
template = require './templates/join_game'

module.exports = class JoinGameView extends View
  template: template
  autoRender: true
  className: 'modal'
  tagName: 'form'

  render: ->
    super
    @el.addEventListener 'submit', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @trigger('setPlayerName', document.getElementById('player_name').value)