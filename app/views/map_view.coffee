Landscaper = require 'lib/landscaper'
View       = require './view'
template   = require './templates/map'
transition_events = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'

module.exports = class MapView extends View
  template: template
  className: "map"
  viewport_padding: 300
  offset_x: 0
  offset_y: 0
  width: 2002
  height: 1500
  padding_top: 80
  padding_bottom: 15

  initialize: ->
    super
    if !!("ontouchstart" of window) or !!("onmsgesturechange" of window)
      @mobile = true
      @viewport_padding = 150
    @landscaper = new Landscaper
      map: @
    @subscribeEvent 'map:pan_to_player', @panToPlayerPosition

  render: ->
    super
    @setDimensions()
    @landscaper.init()
    window.addEventListener 'resize', =>
      @setDimensions()

    # prevent double-tap zoon
    doubleTouchStartTimestamp = 0
    document.addEventListener "touchstart", (event) ->
      now = +(new Date())
      event.preventDefault()  if doubleTouchStartTimestamp + 500 > now
      doubleTouchStartTimestamp = now
      return

    # if @mobile
    document.body.removeChild document.getElementById("keysHints")



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

  panToPlayerPosition: (player, avatar, animate) ->
    @focusedPlayer = player

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
    left_max_pan   = @offset_x - (@viewport_padding - a_width)

    unless (new_x + @offset_x) >= 0 or Math.abs(px + @viewport_padding) >= @width
      @offset_x = new_x
    unless (new_y + @offset_y) >= 0 or Math.abs(py + @viewport_padding) >= @height
      @offset_y = new_y

    @repositionMap(parseInt(@offset_x), parseInt(@offset_y), animate)

  centerMapOn: (x, y, offset_x, offset_y) ->
    viewportCenterX = @viewport.right/2
    viewportCenterY = @viewport.bottom/2

    @offset_x = @offset_x - (x - viewportCenterX - 150) # minus sidebar width
    @offset_y = @offset_y - (y - viewportCenterY)
    if Math.abs(@offset_y - (y - viewportCenterY)) >= @height
      @offset_y = -(y - @viewport.bottom - (@viewport_padding/1.6))

    if Math.abs(@offset_x - (x - viewportCenterX)) >= @width
      @offset_x = -(x - @viewport.right - (@viewport_padding/1.6))
    
    @repositionMap(parseInt(@offset_x), parseInt(@offset_y))


  repositionMap: (left, top, animate) ->
    if animate
      @el.addEventListener "transitionend", @removeTransition, @
      @el.style.transition = 'all .5s'
    @el.style.webkitTransform = "translate3d(#{left}px, #{top}px, 0)"
    @el.style.MozTransform = "translate3d(#{left}px, #{top}px, 0)"

  removeTransition: ->
    @style.transition = null
    @removeEventListener('transitionend', @addAnimation)

  canMoveTo: (x,y, avatar) ->
    if avatar
      @landscaper.checkObstructions x,y,avatar,@

  addTouchEvents: (avatar, event_name) ->
    @el.addEventListener event_name, (e) =>
      avatar.stopMovement()
      x = e.touches[0].clientX - (avatar.width /2)
      y = e.touches[0].clientY - (avatar.height/2)
      @publishEvent 'map:interact', e, x, y
      avatar.travelToPoint(x,y)
