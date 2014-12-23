Modal          = require 'views/modal_view'
WhiteboardView = require 'views/whiteboard_view'
mediator       = require 'lib/mediator'

module.exports = class DrawableWhiteboardView extends WhiteboardView
  temp: []
  template: require 'views/templates/whiteboard'
  className: 'hiross'
  render: ->
    super
    mediator.game_state = 'modal'
    unless @noClose
      @closeButton = document.createElement 'a'
      @el.querySelector('.modal-content-box').appendChild(@closeButton)
      @closeButton.setAttribute('href', '#')
      @closeButton.className = 'close icon-close'
      @closeButton.addEventListener 'click', (e) =>
        e.preventDefault()
        @dispose()

      window.addEventListener 'keyup', @checkEsc
    @el.querySelector('.clear').addEventListener 'click', @clearCanvas

  setupCanvas: ->
    super
    @ctx.lineWidth = '3'
    @canvas.addEventListener 'mousedown', (e) =>
      @temp = []
      @startDraw(e)
    , false
    @canvas.addEventListener 'mousemove', (e) =>
      @draw(e)
    , false
    @canvas.addEventListener 'mouseup', (e) =>
      @endDraw(e)
    , false

    @canvas.addEventListener 'touchstart', (e) =>
      @temp = []
      @startDraw(e)
    , false
    @canvas.addEventListener 'touchmove', (e) =>
      @draw(e)
    , false
    @canvas.addEventListener 'touchend', (e) =>
      @endDraw(e)
    , false

  draw: (e) ->
    return  unless @isActive
    x = e.offsetX or e.layerX - canvas.offsetLeft
    y = e.offsetY or e.layerY - canvas.offsetTop
    @temp.push({x:x, y:y})

    @drawOnCanvas @temp
    return

  startDraw: (e) ->
    @isActive = true
    return

  endDraw: (e) ->
    @isActive = false
    arr = @model.get('plots')
    arr.push(@temp)
    @model.set('plots', arr)
    @model.trigger('draw')
    arr   = []
    mediator.notifier.publish({type: "whiteboard", plots: @model.get('plots')})
    @temp = []
    return

  clearCanvas: (e) =>
    e.stopPropagation()
    e.preventDefault()
    @temp = []
    @model.set('plots', [])
    @endDraw()
    @ctx.clearRect 0 , 0 , @canvas.width, @canvas.height
    @drawOnCanvas @model.get('plots')
    console.log 'clear'

  checkEsc: (e) =>
    if e.keyCode is 27
      e.stopPropagation()
      return @dispose()

  dispose: ->
    mediator.game_state = 'playing'
    window.removeEventListener 'keyup', @checkEsc
    super