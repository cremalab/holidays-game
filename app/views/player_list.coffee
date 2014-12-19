CollectionView = require './collection_view'
Avatar = require './avatar'

module.exports = class PlayerList extends CollectionView
  className: 'playerList'
  initItemView: (model) ->
    if model.isCurrentPlayer()
      template = require './templates/avatar'
    else
      template = require './templates/avatar_head'

    avatar = new Avatar
      model: model
      soulless: true
      template: template
    avatar.el.addEventListener 'click', =>
      @publishEvent "map:pan_to_player", model.get('x_position'), model.get('y_position'), 0, 0, true

    avatar.listenTo avatar, 'messages:focus', =>
      document.body.querySelector('.app-sidebar .scroll-pane').scrollTop = avatar.el.getClientRects()[0].top

    return avatar