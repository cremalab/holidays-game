View       = require './view'
ChatterBox = require 'lib/chatterbox'
mediator   = require 'lib/mediator'

left  = 37
up    = 38
right = 39
down  = 40


module.exports = class Avatar extends View
  directionsByName:
    left: left
    up: up
    right: right
    down: down
  directionsByCode:
    37: "left"
    38: "up"
    39: "right"
    40: "down"
  template: require './templates/avatar'
  autoRender: false
  className: 'avatar'
  movementInc: 8
  movementLoopInc: 30
  moving: false
  activeMovementKeys: []
  movementKeys: [left, up, right, down]
  availableDirections:
    left: true
    right: true
    up: true
    down: true

  initialize: (options) ->
    if options.template
      @template = options.template
    @soulless = options.soulless
    super
    @listenTo @model, "change:avatar-gender change:avatar-hat change:avatar-hair change:avatar-skin change:avatar-coat change:avatar-pants", @updateLook
    @listenTo @model, "dispose", @dispose
    @listenTo @model, "change:z-plane", @updateZIndex
    @subscribeEvent "players:left", @handleLeave
    unless @model.isCurrentPlayer()
      @listenTo @model, "change:moving", =>
        @setMovementClasses()
    unless @soulless
      @listenTo @model, "change:x_position change:y_position change:orientation", @broadCastMove
      @listenTo @, "availableDirectionsUpdated", @updatePosition
      @chatterbox = new ChatterBox
        player: @model
        avatar: @

    @listenTo @model, "change:orientation", @orient
    @listenTo @model, "change:name", @setName

  render: ->
    super
    if @soulless
      @orient(@model, 0)
    else
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
      if @model.isCurrentPlayer()
        @el.addEventListener 'touchstart', (e) =>
          e.preventDefault()
          e.stopPropagation()
          @chatterbox.handleEnter();
      @orient(@model, @model.get('orientation'))
    @updateLook()
    @updateZIndex()

  bindEvents: ->
    if @model.isCurrentPlayer()
      document.addEventListener 'keydown', @handleKeyDown
      document.addEventListener 'keyup', @handleKeyUp

  broadCastMove: (player) ->
    unless player.isCurrentPlayer()
      @positionOnMap()
      @trigger('playerMove', player, @)

  handleKeyDown: (e) =>
    console.log e.keyCode
    unless mediator.game_state is 'modal'
      if @isMovementKey(e) and @activeMovementKeys.indexOf(e.keyCode) < 0
        e.stopPropagation()
        @addActiveMovementKey e.keyCode

        unless @moving or @movementLoop
          @clearMovementClasses()
          @movementLoop = setInterval =>
            @move()
          , @movementLoopInc

      if e.keyCode is 16 # shift
        @addActiveMovementKey e.keyCode
      if e.keyCode is 13 # return/enter
        @chatterbox.handleEnter(e)
      if e.keyCode is 27 # esc
        @chatterbox.disposeBubble(true)

  move: (keys) ->

    @moving = true
    @model.set('moving', true)

    @checkCollision()
    if !@isMovingDirection(up) and
      !@isMovingDirection(down) and
      !@isMovingDirection(left) and
      !@isMovingDirection(right)
        @moving = false
        @model.set('moving', false)
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

  addActiveMovementKey: (key) ->
    if @activeMovementKeys.indexOf(key) < 0
      @activeMovementKeys.push key

  travelToPoint: (x, y) ->
    target =
      x: x
      y: y
    @autopilot.travelToPoint(target, @)

  orient: (player, orientation) ->
    @el.setAttribute('data-pos', orientation)

  handleKeyUp: (e) =>
    @stopMovement(e)
    if e.keyCode is 16 # shift
      @stopMovementDirection e.keyCode


  stopMovement: (e) ->
    if e and e.keyCode
      if @activeMovementKeys.indexOf(e.keyCode) > -1
        @stopMovementDirection(e.keyCode)

      if @activeMovementKeys.length is 0
        @stopMovementLoop()
        @moving = false

      @el.classList.remove @directionsByCode[e.keyCode] if @moving
    else
      @stopMovementLoop()
      @activeMovementKeys = []
      @moving = false

    @setMovementClasses()
    @setOrientation()
    # @trigger 'playerMove', @model.get('x_position'), @model.get('y_position'), @

  isMovementKey: (e) ->
    return @movementKeys.indexOf(e.keyCode) > -1

  isMovingDirection: (keyCode) ->
    if keyCode.isArray
      return keyCode.every (e) ->
        @activeMovementKeys.indexOf(e) > -1
    @activeMovementKeys.indexOf(keyCode) > -1

  isShiftKeyDown: () ->
    return @activeMovementKeys.indexOf(16) > -1

  setMovementClasses: ->
    classList = @el.classList
    classToAdd = ''

    if @model.get('moving')
      classList.add 'moving'
    else
      classList.remove 'moving'

    @clearMovementClasses()

    if @isMovingDirection(up)
      classList.add 'dir-up'

    if @isMovingDirection(down)
      classList.add 'dir-down'

    if @isMovingDirection(left)
      classList.add 'dir-left'

    if @isMovingDirection(right)
      classList.add 'dir-right'

  setOrientation: ->
    cl = @el.classList
    if cl.contains('dir-up') and cl.contains('dir-left')
      if @isShiftKeyDown()
        return @model.set('orientation', 1)
      return @model.set('orientation', 5)
    if cl.contains('dir-up') and cl.contains('dir-right')
      if @isShiftKeyDown()
        return @model.set('orientation', 7)
      return @model.set('orientation', 3)
    if cl.contains('dir-down') and cl.contains('dir-left')
      if @isShiftKeyDown()
        return @model.set('orientation', 3)
      return @model.set('orientation', 7)
    if cl.contains('dir-down') and cl.contains('dir-right')
      if @isShiftKeyDown()
        return @model.set('orientation', 5)
      return @model.set('orientation', 1)
    if cl.contains('dir-up')
      if @isShiftKeyDown()
        return @model.set('orientation', 0)
      return @model.set('orientation', 4)
    if cl.contains('dir-down')
      if @isShiftKeyDown()
        console.log('opposite')
        return @model.set('orientation', 4)
      return @model.set('orientation', 0)
    if cl.contains('dir-right')
      if @isShiftKeyDown()
        return @model.set('orientation', 6)
      return @model.set('orientation', 2)
    if cl.contains('dir-left')
      if @isShiftKeyDown()
        return @model.set('orientation', 2)
      return @model.set('orientation', 6)

  clearMovementClasses: ->
    classList = @el.classList
    classList.remove('dir-up')
    classList.remove('dir-down')
    classList.remove('dir-left')
    classList.remove('dir-right')

  stopMovementLoop: ->
    clearInterval(@movementLoop)
    @model.set('moving', false)
    @movementLoop = null

  stopMovementDirection: (keyCode) ->
    if @activeMovementKeys.indexOf(keyCode) > -1
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

  isCloseEnoughTo: (x, y) ->
    px = Math.abs(x - @model.get('x_position')) < 20
    py = Math.abs(y - @model.get('y_position')) < 20
    return px and py

  setName: ->
    name = @model.get('name')
    @el.querySelector('.player-name').innerText = name

  updateLook: ->
    @el.className = 'avatar'
    @el.classList.add 'active' if @model.get('active')
    @el.setAttribute('data-gender', @model.get('avatar-gender'))
    @el.classList.add @model.get('avatar-hat')
    @el.classList.add @model.get('avatar-hair')
    @el.classList.add @model.get('avatar-skin')
    @el.classList.add @model.get('avatar-coat')
    @el.classList.add @model.get('avatar-pants')
    if @model.isCurrentPlayer()
      @model.save()

  updateZIndex: ->
    @el.style.zIndex = @model.get('y_position')

  handleLeave: (id) ->
    if @model
      if parseInt(id) is parseInt(@model.id)
        @dispose()

  dispose: ->
    document.removeEventListener 'keydown', @handleKeyDown
    document.removeEventListener 'keyup', @handleKeyUp
    super