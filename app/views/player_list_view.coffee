View     = require './view'
template = require './templates/player_list_view'

module.exports = class PlayerListView extends View
  template: template
  render: ->
    super
    @listenTo @model, 'change:name', @render