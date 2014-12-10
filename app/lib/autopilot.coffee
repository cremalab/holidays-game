module.exports = class AutoPilot
  constructor: (avatar, map) ->
    @avatar = avatar
    @map    = map

  travelToPoint: (target) ->

    target.x = target.x - @map.offset_x
    target.y = target.y - @map.offset_y
    @travelAvatar(target)


  travelAvatar: (target) ->
    unless @avatar.moving or @avatar.movementLoop
      @avatar.clearMovementClasses()

      @avatar.movementLoop = setInterval =>
        current = @getCurrentPosition()
        dirs = @avatar.directionsByName

        target.x = target.x
        target.y = target.y

        if @avatar.isCloseEnoughTo(target.x, target.y)
          return @avatar.stopMovement()

        if current.x > target.x and !(Math.abs(current.x - target.x) < 10)
          @avatar.addActiveMovementKey dirs['left']
        else
          @avatar.stopMovementDirection dirs['left']
        
        if current.x < target.x and !(Math.abs(current.x - target.x) < 10)
          @avatar.addActiveMovementKey dirs['right']
        else
          @avatar.stopMovementDirection dirs['right']
        
        if current.y < target.y and !(Math.abs(current.y - target.y) < 10)
          @avatar.addActiveMovementKey dirs['down']
        else
          @avatar.stopMovementDirection dirs['down']

        if current.y > target.y and !(Math.abs(current.y - target.y) < 10)
          @avatar.addActiveMovementKey dirs['up']
        else
          @avatar.stopMovementDirection dirs['up']

        @avatar.move()

      , @avatar.movementLoopInc

  getCurrentPosition: ->
    current = 
      x: @avatar.model.get('x_position')
      y: @avatar.model.get('y_position')
    return current