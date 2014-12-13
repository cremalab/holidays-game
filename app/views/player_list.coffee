CollectionView = require './collection_view'
PlayerListView = require './player_list_view'
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
      console.log 'click head'
      @publishEvent "map:pan_to_player", model, avatar, true
    return avatar