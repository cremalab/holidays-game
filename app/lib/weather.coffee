# based off of http://stackoverflow.com/questions/13983764/creating-falling-snow-using-html-5-and-js

flakeCount = 200
mX = -100
mY = -100
flakes = []

reset = (flake, canvas) ->
  flake.x = Math.floor(Math.random() * canvas.width)
  flake.y = 0
  flake.size = (Math.random() * 3) + 2
  flake.speed = (Math.random() * 1) + 0.5
  flake.velY = flake.speed
  flake.velX = 0
  flake.opacity = (Math.random() * 0.5) + 0.3
  return
startSnow = (canvasId) ->
  requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or window.webkitRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
    window.setTimeout callback, 1000 / 60
    return

  window.requestAnimationFrame = requestAnimationFrame

  canvas = document.getElementById(canvasId)
  ctx = canvas.getContext("2d")
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  canvas.addEventListener "mousemove", (e) ->
    mX = e.clientX
    mY = e.clientY

    return

  i = 0

  while i < flakeCount
    x = Math.floor(Math.random() * canvas.width)
    y = Math.floor(Math.random() * canvas.height)
    size = (Math.random() * 3) + 2
    speed = (Math.random() * 1) + 0.5
    opacity = (Math.random() * 0.5) + 0.3
    flakes.push
      speed: speed
      velY: speed
      velX: 0
      x: x
      y: y
      size: size
      stepSize: (Math.random()) / 30
      step: 0
      angle: 180
      opacity: opacity

    i++
  doSnow(ctx, canvas)
  return

doSnow = (ctx, canvas) ->
  ctx.clearRect 0, 0, canvas.width, canvas.height
  i = 0

  while i < flakeCount
    flake = flakes[i]
    x = mX
    y = mY
    minDist = 150
    x2 = flake.x
    y2 = flake.y
    dist = Math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))
    dx = x2 - x
    dy = y2 - y
    if dist < minDist
      force = minDist / (dist * dist)
      xcomp = (x - x2) / dist
      ycomp = (y - y2) / dist
      deltaV = force / 2
      flake.velX -= deltaV * xcomp
      flake.velY -= deltaV * ycomp
    else
      flake.velX *= .98
      flake.velY = flake.speed  if flake.velY <= flake.speed
      flake.velX += Math.cos(flake.step += .05) * flake.stepSize
    ctx.fillStyle = "rgba(255,255,255," + flake.opacity + ")"
    flake.y += flake.velY
    flake.x += flake.velX
    reset(flake, canvas)  if flake.y >= canvas.height or flake.y <= 0
    reset(flake, canvas)  if flake.x >= canvas.width or flake.x <= 0
    ctx.beginPath()
    ctx.arc flake.x, flake.y, flake.size, 0, Math.PI * 2
    ctx.fill()
    i++
  requestAnimationFrame ->
    doSnow(ctx, canvas)
  return

weather = 
  snow: (canvasId) ->
    startSnow(canvasId)

module.exports = weather