Landscaper        = require 'lib/landscaper'
View              = require './view'
transition_events = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd'
WhiteboardView    = require 'views/whiteboard_view'
FireplaceView    = require 'views/fireplace_view'
mediator          = require 'lib/mediator'

module.exports = class MapView extends View
  className: "map"
  viewport_padding: 300
  offset_x: 0
  offset_y: 0
  width: 2002
  height: 1500
  padding_top: 80
  padding_bottom: 15

  initialize: (options) ->
    @template = options.template or require('./templates/map')
    @mapName = options.mapName or 'westside'

    super
    if !!("ontouchstart" of window) or !!("onmsgesturechange" of window)
      @mobile = true
      document.body.classList.add('touchDevice')
    @landscaper = new Landscaper
      map: @
      landscape: options.landscape
    @subscribeEvent 'map:pan_to_player', @centerMapOn

    # Detect Standalone Web App
    isWebApp = window.navigator.standalone
    if isWebApp
      document.body.classList.add('isWebApp')

  render: ->
    super
    @setDimensions()
    @el.classList.add @mapName
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

    if @mobile
      document.body.removeChild document.getElementById("keysHints")

    @renderWhiteboard() if @mapName is 'eastside'
    @renderFireplace() if @mapName is 'westside'

  renderWhiteboard: ->
    @mini_whiteboard_view = new WhiteboardView
      model: mediator.whiteboard
      container: @el
      autoRender: true
      scale: 0.333

  renderFireplace: ->
    @fireplaceView = new FireplaceView
      container: @el
      autoRender: true

  setDimensions: ->
    @rect = document.body.getClientRects()[0]
    if @mobile
      @viewport_padding =
        x: @rect.width * 0.5
        y: @rect.height * 0.45
    else
      @viewport_padding =
        x: @rect.width * 0.3
        y: @rect.height * 0.3
    @sidebarWidth = document.body.querySelector('.sidebar').getClientRects()[0].width
    @viewport =
      left:   @rect.left + @viewport_padding.x - @sidebarWidth
      top:    @rect.top + @viewport_padding.y
      right:  @rect.right - @viewport_padding.x
      bottom: @rect.bottom - @viewport_padding.y


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
    if avatar and avatar.model
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
    left_max_pan   = @offset_x - (@viewport_padding.x - a_width)

    unless (new_x + @offset_x) >= 0 or Math.abs(px + @viewport_padding.x - @sidebarWidth) >= @width
      @offset_x = new_x
    unless (new_y + @offset_y) >= 0 or Math.abs(py + @viewport_padding.y) >= @height
      @offset_y = new_y

    @repositionMap(parseInt(@offset_x), parseInt(@offset_y), animate)

  centerMapOn: (x, y, offset_x, offset_y, animate) ->
    if animate
      @player_centered = false
    viewportCenterX = @viewport.right/2
    viewportCenterY = @viewport.bottom/2

    new_x = viewportCenterX - x + @sidebarWidth
    new_y = viewportCenterY - y

    @offset_x = viewportCenterX - x + @sidebarWidth
    @offset_y = viewportCenterY - y

    if y + @viewport_padding.y >= @height
      @offset_y = new_y + viewportCenterY + @viewport_padding.y/2 - 21
    if x + @viewport_padding.x >= @width
      @offset_x = new_x + viewportCenterX
    if new_y > 0
      @offset_y = 0
    if new_x > 0
      @offset_x = 0

    @repositionMap(parseInt(@offset_x), parseInt(@offset_y), animate)


  repositionMap: (left, top, animate) ->
    if animate
      @el.style.transition = 'all .8s'
      setTimeout =>
        @removeTransition()
      , 800
    @el.style.webkitTransform = "translate3d(#{left}px, #{top}px, 0)"
    @el.style.MozTransform = "translate3d(#{left}px, #{top}px, 0)"
    @el.style.transform = "translate3d(#{left}px, #{top}px, 0)"

  removeTransition: ->
    @el.style.transition = null

  canMoveTo: (x,y, avatar) ->
    if avatar
      @landscaper.checkObstructions x,y,avatar,@

  addTouchEvents: (avatar, event_name) ->
    @el.addEventListener event_name, (e) =>
      avatar.stopMovement()
      x = e.touches[0].clientX - @sidebarWidth - (avatar.width /2)
      y = e.touches[0].clientY - (avatar.height/2)
      @publishEvent 'map:interact', e, x, y
      avatar.travelToPoint(x,y)

  dispose: ->
    @landscaper.dispose()
    @landscaper = null
    super
