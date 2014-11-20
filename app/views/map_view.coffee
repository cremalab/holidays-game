View = require './view'
template = require './templates/map'

module.exports = class MapView extends View
  template: template
  className: "map"
  viewport_padding: 100
  offset_x: 0
  offset_y: 0

  render: ->
    super
    @setDimensions()

  setDimensions: ->
    @rect = document.body.getClientRects()[0]
    @viewport = 
      left:   @rect.left + @viewport_padding
      top:    @rect.top + @viewport_padding
      right:  @rect.right - @viewport_padding
      bottom: @rect.bottom - @viewport_padding

  spawnPlayer: (player, avatar) ->
    avatar.container = @el
    avatar.render()

  checkPlayerPosition: (player, avatar) ->

    px = player.get('x_position')
    py = player.get('y_position')

    within_x = px > @viewport.left and px < @viewport.right
    within_y = py > @viewport.top and py < @viewport.bottom
    within_rect = within_x and within_y

    pan_right = px > ((@viewport.right - @offset_x) - avatar.width)
    pan_left  = px < (@viewport.left - @offset_x)
    pan_down  = py > ((@viewport.bottom - @offset_y) - avatar.height)
    pan_up    = py < (@viewport.top - @offset_y)

    if pan_left
      @offset_x = @rect.left + (@viewport.left - px)
    if pan_right
      @offset_x = @rect.left + ((@viewport.right - avatar.width) - px)
    if pan_up
      @offset_y = @rect.top + (@viewport.top - py)
    if pan_down
      @offset_y = @rect.top + ((@viewport.bottom - avatar.height) - py)

    @repositionMap(@offset_x, @offset_y)


  repositionMap: (left, top) ->
    @el.style.webkitTransform = "translate3d(#{left}px, #{top}px, 0)"
