View = require './view'

module.exports = class Avatar extends View
  template: require './templates/avatar'
  autoRender: false
  movementInc: 5
  moving: false
  activeMovementKeys: []
  movementKeys: [37,38,39,40]

  render: ->
    super
    @bindEvents()

  bindEvents: ->
    console.log 'bind'
    document.addEventListener 'keydown', (e) =>
      @handleKeyDown(e) if @isMovementKey(e)
    document.addEventListener 'keyup', (e) =>
      @stopMovement(e)  if @isMovementKey(e)

  handleKeyDown: (e) ->
    e.stopPropagation()
    @stopMovement()

    if @isMovementKey(e) and @activeMovementKeys.indexOf(e.keyCode) < 0
      @activeMovementKeys.push e.keyCode

      unless @moving
        @movementLoop = setInterval =>
          @move()
        , 20


  move: (keys) ->
    left  = @activeMovementKeys.indexOf(37) > -1
    up    = @activeMovementKeys.indexOf(38) > -1
    right = @activeMovementKeys.indexOf(39) > -1
    down  = @activeMovementKeys.indexOf(40) > -1

    @moving = true
    if up
      @model.set('y_position', @model.get('y_position') + -@movementInc)
    if down
      @model.set('y_position', @model.get('y_position') + @movementInc)
    if left
      @model.set('x_position', @model.get('x_position') + -@movementInc)
    if right
      @model.set('x_position', @model.get('x_position') + @movementInc)

    @el.style.webkitTransform = "translate3d(#{@model.position()}, 0)"

  stopMovement: (e) ->
    if e and e.keyCode and @isMovementKey(e)
      @activeMovementKeys.splice(@activeMovementKeys.indexOf(e.keyCode), 1)
      unless @activeMovementKeys.length
        @moving = false
        clearInterval(@movementLoop)

  isMovementKey: (e) ->
    return @movementKeys.indexOf(e.keyCode) > -1
