View = require './view'

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
  movementInc: 10
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
    @listenTo @model, "change:x_position change:y_position", @broadCastMove

  render: ->
    super
    @positionOnMap()
    @bindEvents()
    @setDimensions()

  bindEvents: ->
    document.addEventListener 'keydown', (e) =>
      @handleKeyDown(e) if @isMovementKey(e)
    document.addEventListener 'keyup', (e) =>
      @stopMovement(e)

  broadCastMove: (player) ->
    @trigger('playerMove', player, @)

  handleKeyDown: (e) ->
    e.stopPropagation()

    if @isMovementKey(e) and @activeMovementKeys.indexOf(e.keyCode) < 0
      @activeMovementKeys.push e.keyCode

      unless @moving or @movementLoop
        @clearMovementClasses()
        @movementLoop = setInterval =>
          @move()
        , @movementLoopInc


  move: (keys) ->

    @moving = true

    @checkCollision()
    if !@isMovingDirection(up) and 
      !@isMovingDirection(down) and 
      !@isMovingDirection(left) and 
      !@isMovingDirection(right)
        @moving = false
        @stopMovementLoop()


    if @isMovingDirection(up)
      @model.set('y_position', @model.get('y_position') + -@movementInc)
    if @isMovingDirection(down)
      @model.set('y_position', @model.get('y_position') + @movementInc)
    if @isMovingDirection(left)
      @model.set('x_position', @model.get('x_position') + -@movementInc)
    if @isMovingDirection(right)
      @model.set('x_position', @model.get('x_position') + @movementInc)

    @setMovementClasses()

    @positionOnMap()

  positionOnMap: ->
    @position_x = @model.get('x_position')
    @position_y = @model.get('y_position')
    @el.style.webkitTransform = "translate3d(#{@model.position()}, 0)"

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

  isMovementKey: (e) ->
    return @movementKeys.indexOf(e.keyCode) > -1

  isMovingDirection: (keyCode) ->
    @activeMovementKeys.indexOf(keyCode) > -1

  setMovementClasses: ->
    classList = @el.classList
    if @moving
      classList.add 'moving'
    else
      classList.remove 'moving'

    if @isMovingDirection(up)
      classList.add 'up'
      classList.remove 'down'
    if @isMovingDirection(down)
      classList.add 'down'
      classList.remove 'up'
    if @isMovingDirection(left)
      classList.add 'left'
      classList.remove 'right'
    if @isMovingDirection(right)
      classList.add 'right'
      classList.remove 'left'

  clearMovementClasses: ->
    classList = @el.classList
    classList.remove('up')
    classList.remove('down')
    classList.remove('left')
    classList.remove('right')

  stopMovementLoop: ->
    clearInterval(@movementLoop)
    @movementLoop = null

  stopMovementDirection: (keyCode) ->
    @activeMovementKeys.splice(@activeMovementKeys.indexOf(keyCode), 1)

  setDimensions: ->
    setTimeout(=>
      avatar_rect = @el.getClientRects()[0]
      @width = avatar_rect.right - avatar_rect.left
      @height = avatar_rect.bottom - avatar_rect.top
    , 0)

  checkCollision: ->
    blocked_up    = @isMovingDirection(up) and !@availableDirections.up
    blocked_down  = @isMovingDirection(down) and !@availableDirections.down
    blocked_left  = @isMovingDirection(left) and !@availableDirections.left
    blocked_right = @isMovingDirection(right) and !@availableDirections.right

    @stopMovementDirection(up) if blocked_up
    @stopMovementDirection(down) if blocked_down
    @stopMovementDirection(left) if blocked_left
    @stopMovementDirection(right) if blocked_right

    console.log 'blocked_up' if blocked_up
    console.log 'blocked_down' if blocked_down
    console.log 'blocked_left' if blocked_left
    console.log 'blocked_right' if blocked_right

    # @collision = true

      # @stopMovement()

