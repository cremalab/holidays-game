Activist = require 'lib/activist'

module.exports = class Landscaper
  landscape: require 'lib/landscape'
  obstructions: []
  constructor: (options) ->
    @map = options.map
  init: ->
    @activist = new Activist
    for obstruction in @landscape
      if obstruction.hasOwnProperty 'src'
        svg = @createObstructionGraphic(obstruction)
        obstruction = @activist.activate(obstruction)
        unless obstruction.ghosty
          @obstructions.push obstruction


  createObstructionGraphic: (obstruction) ->
    position = "#{obstruction.x}px, #{obstruction.y}px"
    img = document.createElement('img')
    img.id = obstruction.id
    img.setAttribute('src', obstruction.src)
    img = @map.el.appendChild(img)

    extension = obstruction.src.split(".")
    extension = extension[extension.length-1]
    img.style.top  = "#{obstruction.y}px"
    img.style.left = "#{obstruction.x}px"
    img.classList.add 'obstruction'

    if extension is 'svg'
      @createSVG(obstruction, img)
    else
      @createImage(obstruction, img)


  createSVG: (obstruction, img) ->

    SVGInjector img, {}, ->
      img = document.querySelector "svg##{obstruction.id}"
      box = img.getBBox()

      img.x      = obstruction.x
      img.y      = obstruction.y
      obstruction.left   = obstruction.x
      obstruction.top    = obstruction.y
      obstruction.right  = obstruction.x + box.width
      obstruction.bottom = obstruction.y + box.height
      img.classList.add 'svg'

      obstruction.svg = img

  createImage: (obstruction, img) ->
    img  = document.getElementById obstruction.id
    imagesLoaded img, ->
      rect = img.getClientRects()[0]
      obstruction.left = obstruction.x
      obstruction.top  = obstruction.y
      obstruction.right = obstruction.x + rect.width
      obstruction.bottom = obstruction.y + rect.height
      img.classList.add 'img'

      obstruction.img = img


  checkObstructions: (x, y, avatar, map) ->
    availableDirections =
      right: true
      left: true
      up: true
      down: true

    @rights = []
    @ups    = []
    @lefts  = []
    @downs  = []

    for obstruction in @obstructions

      @getObstructionShape(obstruction, x, y, avatar)

    availableDirections.right = @rights.indexOf(false) < 0
    availableDirections.left  = @lefts.indexOf(false) < 0
    availableDirections.up    = @ups.indexOf(false) < 0
    availableDirections.down  = @downs.indexOf(false) < 0

    if (x + avatar.width) > map.width
      availableDirections.right = false
    if x < 0
      availableDirections.left = false
    if (y + avatar.height + map.padding_bottom) >= map.height
      availableDirections.down = false
    if (y + avatar.height - map.padding_top) < 0
      availableDirections.up = false

    avatar.availableDirections = availableDirections
    avatar.trigger 'availableDirectionsUpdated', x, y



  getObstructionShape: (obstruction, x, y, avatar) ->
    if obstruction.svg
      avatarRect = obstruction.svg.createSVGRect()
    else
      avatarRect = avatar.rect

    avatarRect.height = avatar.height
    avatarRect.width = avatar.width
    player = avatar.model
    avatarRect.x = player.get('x_position')
    avatarRect.y = player.get('y_position')
    @checkIntersections(obstruction, avatarRect, player, x, y, avatar)
    @checkProximities(avatarRect, obstruction, x, y, avatar) if obstruction.proximity


  checkIntersections: (obstruction, avatarRect, player, x, y, avatar) ->
    if x < avatarRect.x
      avatarRect.x = x
      @determineDirections(avatarRect, obstruction, @lefts, 'right', x, y, avatar)
      avatarRect.x = player.get('x_position')
    if x > avatarRect.x
      avatarRect.x = x
      @determineDirections(avatarRect, obstruction, @rights, 'left', x, y, avatar)
      avatarRect.x = player.get('x_position')
    if y < avatarRect.y
      avatarRect.y = y
      @determineDirections(avatarRect, obstruction, @ups, 'bottom', x, y, avatar)
      avatarRect.y = player.get('y_position')
    if y > avatarRect.y
      avatarRect.y = y
      @determineDirections(avatarRect, obstruction, @downs, 'top', x, y, avatar)
      avatarRect.y = player.get('y_position')


  checkProximities: (avatarRect, obstruction, x, y, avatar) ->
    radius = obstruction.proximity.radius
    if !radius
      throw new Error "Proximity declaration of #{obstruction.id} needs a radius"

    proximity =
      top: obstruction.top - radius
      bottom: obstruction.botom + radius
      left: obstruction.left - radius
      right: obstruction.right + radius

    if @avatarOverlaps(avatar, proximity, x, y)
      unless obstruction.current_player_within
        obstruction.raiseEvent 'enterProximity'
        obstruction.current_player_within = true
    else
      if obstruction.current_player_within
        obstruction.raiseEvent 'leaveProximity'
        obstruction.current_player_within = false


  determineDirections: (avatarRect, obstruction, array, dir, x, y, avatar) ->
    if obstruction.svg
      @determineSVGDirections(avatarRect, obstruction, array, dir, x, y, avatar)
    else
      @determineImgDirections(avatarRect, obstruction, array, dir, x, y, avatar)

  determineImgDirections: (avatarRect, obstruction, array, dir, x, y, avatar) ->
    # use avatar.width to ignore player name making it wider

    if @avatarOverlaps(avatar, obstruction, x, y)
      array.push false
      @dispatchHitActions(obstruction, dir, x, y, avatar)
    else
      array.push true

  determineSVGDirections: (avatarRect, obstruction, array, dir, x, y, avatar) ->
    if obstruction.svg.getIntersectionList(avatarRect, null).length < 1
      array.push true
    else
      array.push false
      @dispatchHitActions(obstruction, dir, x, y, avatar)

  dispatchHitActions: (obstruction, dir, x, y, avatar) ->
    options =
      avatar: avatar
      x: x
      y: y
    obstruction.raiseEvent "hit_#{dir}", options
    obstruction.raiseEvent "hit_any", options

  avatarOverlaps: (a, b, x, y) ->
    aLeftOfB  = (x + a.width) < b.left
    aRightOfB = x > b.right
    aBelowB   = y > b.bottom
    aAboveB   = (y + a.height) < b.top

    return !( aLeftOfB || aRightOfB || aAboveB || aBelowB )
