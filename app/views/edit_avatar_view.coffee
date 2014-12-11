JoinGameView = require 'views/join_game_view'

module.exports = class EditAvatarView extends JoinGameView
  noClose: false
  render: ->
    super
    @bindForm()
    @el.querySelector('button').innerText = "Save Avatar"

  bindForm: ->
    for attribute in Object.keys(@model.attributes)
      val = @model.get(attribute)
      input = @el.querySelector("input[name='#{attribute}']")
      if input
        if input.type is 'radio'
          input = @el.querySelector("input[name='#{attribute}'][value='#{val}']")
          if input
            input.checked = true
        else
          input.value = val