# Adaptation of http://www.pubnub.com/blog/multiuser-draw-html5-canvas-tutorial/

Modal    = require 'views/modal_view'
View     = require 'views/view'
mediator = require 'lib/mediator'

module.exports = class WhiteBoard extends View
  isActive: false
  template: require './templates/mini_whiteboard'
  className: 'obstruction whiteboard mini'
  initialize: (options) ->
    @scale = options.scale or 1
    super
  render: ->
    super
    @listenTo @model, 'cleared', @clearCanvas
    setTimeout =>
      @setupCanvas()
      for path in @model.get('plots')
        @drawOnCanvas path
    , 0

  setupCanvas: ->
    @listenTo @model, "change", =>
      @drawFromStream()
    @listenTo @model, 'draw', ->
      @drawFromStream()
    @canvas = @el.querySelector('canvas')
    @ctx = @canvas.getContext('2d')
    @ctx.lineWidth = '1'

  drawOnCanvas: (plots) ->
    if plots.length
      @ctx.beginPath()
      @ctx.moveTo (plots[0].x * @scale), (plots[0].y * @scale)
      i = 1

      while i < plots.length
        @ctx.strokeStyle = plots[i].color
        @ctx.lineTo (plots[i].x * @scale), (plots[i].y * @scale)
        i++
      @ctx.stroke()
      return

  clearCanvas: =>
    @temp = []
    @model.set('plots', [])
    @ctx.clearRect 0 , 0 , @canvas.width, @canvas.height

  drawFromStream: ->
    @ctx.beginPath()
    if @model.get('plots').length
      for path in @model.get('plots')
        @drawOnCanvas path
    else
      @clearCanvas()
    