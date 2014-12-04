Landscaper = require 'lib/landscaper'
View       = require './view'
template   = require './templates/map'

module.exports = class MapView extends View
  template: template
  className: "map"
  viewport_padding: 300
  offset_x: 0
  offset_y: 0
  width: 5769
  height: 4102

  initialize: ->
    super
    @landscaper = new Landscaper
      map: @

  render: ->
    super
    @setDimensions()
    @landscaper.init()
    window.addEventListener 'resize', =>
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
    setTimeout =>
      @checkPlayerPosition(player, avatar)
    , 0

  checkPlayerPosition: (px,py,avatar) ->
    @canMoveTo(px, py, avatar)

    within_x = px > @viewport.left and px < @viewport.right
    within_y = py > @viewport.top and py < @viewport.bottom
    within_rect = within_x and within_y
    if avatar
      @panToPlayerPosition(avatar.model, avatar) if avatar.model.isCurrentPlayer()

  panToPlayerPosition: (player, avatar) ->
    px = player.get('x_position')
    py = player.get('y_position')

    a_height = avatar.height or 0
    a_width = avatar.width or 0

    pan_right = px > ((@viewport.right - @offset_x) - a_width)
    pan_left  = px < (@viewport.left - @offset_x)
    pan_down  = py > ((@viewport.bottom - @offset_y) - a_height)
    pan_up    = py < (@viewport.top - @offset_y)

    new_x = @offset_x
    new_y = @offset_y

    if pan_left
      new_x = @rect.left + (@viewport.left - px)
    if pan_right
      new_x = @rect.left + ((@viewport.right - avatar.width) - px)
    if pan_up
      new_y = @rect.top + (@viewport.top - py)
    if pan_down
      new_y = @rect.top + ((@viewport.bottom - a_height) - py)

    # Don't pan if it will reveal beyond the edge of the map
    unless (new_x + @offset_x) >= 0
      @offset_x = new_x
    unless (new_y + @offset_y) >= 0
      @offset_y = new_y

    @repositionMap(@offset_x, @offset_y)

  repositionMap: (left, top) ->
    @el.style.webkitTransform = "translate3d(#{left}px, #{top}px, 0)"

  canMoveTo: (x,y, avatar) ->
    if avatar
      @landscaper.checkObstructions x,y,avatar,@
