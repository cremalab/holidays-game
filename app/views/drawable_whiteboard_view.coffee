Modal          = require 'views/modal_view'
WhiteboardView = require 'views/whiteboard_view'
MarkersView    = require 'views/markers_view'
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
    @el.querySelector('.clear').addEventListener 'click', (e) =>
      e.stopPropagation()
      e.preventDefault()
      @model.set('plots', [])
      @model.trigger('cleared')

    markers = new Backbone.Collection [
      color: "#ff0000"
    ,
      color: "#ff8000"
    ,
      color: "#ffff00"
    ,
      color: "#00ff00"
    ,
      color: "#0000ff"
    ,
      color: "#800080"
    ]
    @markersView = new MarkersView
      collection: markers
      el: @el.querySelector('.whiteboard-markers')
      autoRender: true

    @listenTo markers, 'chosen', (color) =>
      @ctx.strokeStyle = color
      @activeColor = color

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
    @temp.push({x:x, y:y, color: @activeColor})

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

  checkEsc: (e) =>
    if e.keyCode is 27
      e.stopPropagation()
      return @dispose()

  dispose: ->
    mediator.game_state = 'playing'
    window.removeEventListener 'keyup', @checkEsc
    super