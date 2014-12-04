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
    # img.style.webkitTransform = "translate3d(#{position},0)"
    # img.style.transform = "translate3d(#{position}, 0)"
    # img.style.top = obstruction.y
    # img.style.left = obstruction.x
    SVGInjector img, {}, ->
      img = document.querySelector "svg##{obstruction.id}"
      img.setAttribute('x', '100')
      img.setAttribute('y', '500')
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

  checkObstructions: (x, y, avatar, availableDirections, cb) ->
    for obstruction in @obstructions
      avatarRect = obstruction.svg.createSVGRect()
      avatarRect.height = avatar.height
      avatarRect.width = avatar.width
      player = avatar.model
      avatarRect.x = player.get('x_position')
      avatarRect.y = player.get('y_position')

      if x < avatarRect.x
        avatarRect.x = x
        availableDirections.left = obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.x = player.get('x_position')
      if x > avatarRect.x
        avatarRect.x = x
        availableDirections.right = obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.x = player.get('x_position')
      if y < avatarRect.y
        avatarRect.y = y
        availableDirections.up = obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.y = player.get('y_position')
      if y > avatarRect.y
        avatarRect.y = y
        availableDirections.down = obstruction.svg.getIntersectionList(avatarRect, null).length < 1
        avatarRect.y = player.get('y_position')
    
    avatar.availableDirections = availableDirections
    avatar.trigger 'availableDirectionsUpdated', x, y
