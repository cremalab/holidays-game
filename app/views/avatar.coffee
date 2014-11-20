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
  movementInc: 5
  movementLoopInc: 20
  moving: false
  activeMovementKeys: []
  movementKeys: [left, up, right, down]

  render: ->
    super
    @bindEvents()

  bindEvents: ->
    document.addEventListener 'keydown', (e) =>
      @handleKeyDown(e) if @isMovementKey(e)
    document.addEventListener 'keyup', (e) =>
      @stopMovement(e)

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

    @el.style.webkitTransform = "translate3d(#{@model.position()}, 0)"

  stopMovement: (e) ->
    if e and e.keyCode
      if @activeMovementKeys.indexOf(e.keyCode) > -1
        console.log @activeMovementKeys.splice(@activeMovementKeys.indexOf(e.keyCode), 1)

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




