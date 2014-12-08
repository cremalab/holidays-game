View       = require './view'
ChatterBox = require 'lib/chatterbox'

left  = 37
up    = 38
right = 39
down  = 40

directionsByName =
  left: left
  up: up
  right: right
  down: down

directionsByCode =
  37: "left"
  38: "up"
  39: "right"
  40: "down"

module.exports = class Avatar extends View
  template: require './templates/avatar'
  autoRender: false
  className: 'avatar'
  movementInc: 5
  movementLoopInc: 30
  moving: false
  activeMovementKeys: []
  movementKeys: [left, up, right, down]
  availableDirections:
    left: true
    right: true
    up: true
    down: true

  initialize: ->
    super
    @listenTo @model, "change:x_position change:y_position change:orientation", @broadCastMove
    @listenTo @model, "change:orientation", @orient
    @listenTo @model, "change:name", @setName
    @chatterbox = new ChatterBox
      player: @model
      avatar: @
    @listenTo @, "availableDirectionsUpdated", @updatePosition

  render: ->
    super
    @positionOnMap()
    @bindEvents()
    @el.setAttribute('data-pos', 7)
    setTimeout(=>
      @rect = @el.getClientRects()[0]
      @boundingRect = @el.getBoundingClientRect()
      @setDimensions()
    , 0)
    if @model.get('active')
      @el.classList.add 'active'

  bindEvents: ->
    if @model.isCurrentPlayer()
      document.addEventListener 'keydown', @handleKeyDown
      document.addEventListener 'keyup', @handleKeyUp

  broadCastMove: (player) ->
    unless player.isCurrentPlayer()
      @positionOnMap()
      @trigger('playerMove', player, @)

  handleKeyDown: (e) =>
    e.stopPropagation()

    if @isMovementKey(e) and @activeMovementKeys.indexOf(e.keyCode) < 0
      @activeMovementKeys.push e.keyCode

      unless @moving or @movementLoop
        @clearMovementClasses()
        @movementLoop = setInterval =>
          @move()
        , @movementLoopInc

    if e.keyCode is 13 # return/enter
      @chatterbox.handleEnter(e)
    if e.keyCode is 27 # esc
      @chatterbox.disposeBubble(true)


  move: (keys) ->

    @moving = true

    @checkCollision()
    if !@isMovingDirection(up) and
      !@isMovingDirection(down) and
      !@isMovingDirection(left) and
      !@isMovingDirection(right)
        @moving = false
        @stopMovementLoop()

    new_x = @model.get('x_position')
    new_y = @model.get('y_position')

    if @isMovingDirection(up)
      new_y = @model.get('y_position') + -@movementInc
    if @isMovingDirection(down)
      new_y = @model.get('y_position') + @movementInc
    if @isMovingDirection(left)
      new_x = @model.get('x_position') + -@movementInc
    if @isMovingDirection(right)
      new_x = @model.get('x_position') + @movementInc

    # Let MapView know the player wants to move
    @trigger 'playerMove', new_x, new_y, @

    @setMovementClasses()
    @setOrientation()

    @positionOnMap()

  positionOnMap: ->
    @position_x = @model.get('x_position')
    @position_y = @model.get('y_position')
    @el.style.webkitTransform = "translate3d(#{@model.position()}, 0)"
    @el.style.transform = "translate3d(#{@model.position()}, 0)"

  orient: (player, orientation) ->
    @el.setAttribute('data-pos', orientation)

  handleKeyUp: (e) =>
    @stopMovement(e)

  stopMovement: (e) ->
    if e and e.keyCode
      if @activeMovementKeys.indexOf(e.keyCode) > -1
        @stopMovementDirection(e.keyCode)

      if @activeMovementKeys.length is 0
        @stopMovementLoop()
        @moving = false

      @el.classList.remove directionsByCode[e.keyCode] if @moving
    else
      @stopMovementLoop()
      @activeMovementKeys = []
      @moving = false

    @setMovementClasses()
    @setOrientation()

  isMovementKey: (e) ->
    return @movementKeys.indexOf(e.keyCode) > -1

  isMovingDirection: (keyCode) ->
    if keyCode.isArray
      return keyCode.every (e) ->
        @activeMovementKeys.indexOf(e) > -1

    @activeMovementKeys.indexOf(keyCode) > -1

  setMovementClasses: ->
    classList = @el.classList
    if @moving
      classList.add 'moving'
    else
      classList.remove 'moving'

    if @isMovingDirection(up)
      classList.add 'dir-up'
    else
      classList.remove 'dir-up'

    if @isMovingDirection(down)
      classList.add 'dir-down'
    else
      classList.remove 'dir-down'
    if @isMovingDirection(left)
      classList.add 'dir-left'
    else
      classList.remove 'dir-left'
    if @isMovingDirection(right)
      classList.add 'dir-right'
    else
      classList.remove 'dir-right'


  setOrientation: ->
    cl = @el.classList
    if cl.contains('dir-up') and cl.contains('dir-left')
      return @model.set('orientation', 5)
    if cl.contains('dir-up') and cl.contains('dir-right')
      return @model.set('orientation', 3)
    if cl.contains('dir-down') and cl.contains('dir-left')
      return @model.set('orientation', 7)
    if cl.contains('dir-down') and cl.contains('dir-right')
      return @model.set('orientation', 1)
    if cl.contains('dir-up')
      return @model.set('orientation', 4)
    if cl.contains('dir-down')
      return @model.set('orientation', 0)
    if cl.contains('dir-right')
      return @model.set('orientation', 2)
    if cl.contains('dir-left')
      return @model.set('orientation', 6)

  clearMovementClasses: ->
    classList = @el.classList
    classList.remove('dir-up')
    classList.remove('dir-down')
    classList.remove('dir-left')
    classList.remove('dir-right')

  stopMovementLoop: ->
    clearInterval(@movementLoop)
    @movementLoop = null

  stopMovementDirection: (keyCode) ->
    @activeMovementKeys.splice(@activeMovementKeys.indexOf(keyCode), 1)

  setDimensions: ->
    @width = @rect.right - @rect.left
    @height = @rect.bottom - @rect.top

  checkCollision: ->
    blocked_up    = @isMovingDirection(up) and !@availableDirections.up
    blocked_down  = @isMovingDirection(down) and !@availableDirections.down
    blocked_left  = @isMovingDirection(left) and !@availableDirections.left
    blocked_right = @isMovingDirection(right) and !@availableDirections.right

    @stopMovementDirection(up) if blocked_up
    @stopMovementDirection(down) if blocked_down
    @stopMovementDirection(left) if blocked_left
    @stopMovementDirection(right) if blocked_right

  updatePosition: (new_x,new_y) ->
    if  (new_x > @model.get('x_position') and @availableDirections.right) or
        (new_x < @model.get('x_position') and @availableDirections.left)
          @model.set('x_position', new_x)

    if  (new_y > @model.get('y_position') and @availableDirections.down) or
        (new_y < @model.get('y_position') and @availableDirections.up)
          @model.set('y_position', new_y)

  setName: ->
    name = @model.get('name')
    @el.querySelector('.player-name').innerText = name

  dispose: ->
    document.removeEventListener 'keydown', @handleKeyDown
    document.removeEventListener 'keyup', @handleKeyUp
    super