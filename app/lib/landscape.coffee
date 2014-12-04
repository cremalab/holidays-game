module.exports = [
  id: "bar"
  src: "images/bar.svg"
  x: 500
  y: 300
  onHit:
    left: (item, options) ->
      item.svg.style.left = options.x + options.avatar.width
      options.avatar.model.set('x_position', options.x)

]