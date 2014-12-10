module.exports = [
  id: "table"
  src: "images/table.png"
  x: 600
  y: 500
  ghosty: true
  onHit:
    # left, right, top, bottom, any ->
    left: (item, options) ->
      alert 'you hit the left side of the table. +100 XP'
]