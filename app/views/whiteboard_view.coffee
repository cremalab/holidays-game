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
    if @scale < 1
      x_scale = @scale * 1.6
    else
      x_scale = @scale
    if plots.length
      @ctx.beginPath()
      @ctx.moveTo (plots[0].x * (x_scale)), (plots[0].y * @scale)
      i = 1

      while i < plots.length
        @ctx.lineTo (plots[i].x * (x_scale)), (plots[i].y * @scale)
        i++
      @ctx.stroke()
      return

  drawFromStream: ->
    console.log 'draw'
    @ctx.beginPath()
    for path in @model.get('plots')
      @drawOnCanvas path
    return