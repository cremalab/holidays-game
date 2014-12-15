Modal    = require 'views/modal_view'
mediator = require 'lib/mediator'

module.exports = 
  team_photo: (map) ->
    unless mediator.game_state is 'modal'
      view = new Modal
        container: document.body
        className: 'modal'
        template: require 'views/templates/team_photo'
        autoRender: true
      mediator.game_state = 'modal'
  disco: (map) ->
    if !@audio
      @audio = new Audio('https://s3.amazonaws.com/cremalab/disco.mp3')
    
    if @audio.paused
      map.el.classList.add 'disco-time'
      @audio.play()
      @audio.addEventListener('ended', ->
        this.currentTime = 0
        this.play()
      , false)
    else
      map.el.classList.remove 'disco-time'
      @audio.currentTime = 0
      @audio.pause()
      