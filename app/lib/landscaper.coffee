module.exports = class Landscaper
  landscape: require 'lib/landscape'
  obstructions: []
  constructor: (options) ->
    @map = options.map
  init: ->
    for obstruction in @landscape
      if obstruction.hasOwnProperty 'src'
        svg = @createSVG(obstruction)
        @obstructions.push obstruction

  createSVG: (obstruction) ->
    position = "#{obstruction.x}px, #{obstruction.y}px"
    img = document.createElement('img')
    img.id = obstruction.id
    img.setAttribute('src', obstruction.src)
    img = @map.el.appendChild(img)

    SVGInjector img, {}, ->
      img = document.querySelector "svg##{obstruction.id}"
      box = img.getBBox()

      img.x      = obstruction.x
      img.y      = obstruction.y
      obstruction.left   = obstruction.x
      obstruction.top    = obstruction.y
      obstruction.right  = obstruction.x + box.width
      obstruction.bottom = obstruction.y + box.height

      img.style.top = obstruction.y
      img.style.left = obstruction.x

      img.classList.add 'svg'
      img.classList.add 'obstruction'

      obstruction.svg = img

  checkObstructions: (x, y, avatar, map) ->
    availableDirections = 
      right: true
      left: true
      up: true
      down: true

    rights = []
    ups    = []
    lefts  = []
    downs  = []

    for obstruction in @obstructions
      avatarRect = obstruction.svg.createSVGRect()
      avatarRect.height = avatar.height
      avatarRect.width = avatar.width
      player = avatar.model
      avatarRect.x = player.get('x_position')
      avatarRect.y = player.get('y_position')

      if x < avatarRect.x
        avatarRect.x = x
        lefts.push obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.x = player.get('x_position')
      if x > avatarRect.x
        avatarRect.x = x
        rights.push obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.x = player.get('x_position')
      if y < avatarRect.y
        avatarRect.y = y
        ups.push obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.y = player.get('y_position')
      if y > avatarRect.y
        avatarRect.y = y
        downs.push obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.y = player.get('y_position')

    availableDirections.right = rights.indexOf(false) < 0
    availableDirections.left  = lefts.indexOf(false) < 0
    availableDirections.up    = ups.indexOf(false) < 0
    availableDirections.down  = downs.indexOf(false) < 0

    if x > map.width
      availableDirections.right = false
    if x < 0
      availableDirections.left = false
    if y > map.height
      availableDirections.down = false
    if y < 0
      availableDirections.up = false
    
    avatar.availableDirections = availableDirections
    avatar.trigger 'availableDirectionsUpdated', x, y
