CollectionView = require './collection_view'
PlayerListView = require './player_list_view'
Avatar = require './avatar'


module.exports = class PlayerList extends CollectionView
  initItemView: (model) ->
    if model.isCurrentPlayer()
      template = require './templates/avatar'
    else
      template = require './templates/avatar_head'

    new Avatar
      model: model
      soulless: true
      template: template
