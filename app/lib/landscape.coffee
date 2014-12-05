module.exports = [
  id: "bar"
  src: "images/bar.svg"
  x: 500
  y: 300
  onHit:
    left: (item, options) ->
      alert 'you hit the left side of the table. +100 Gold'
]