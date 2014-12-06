module.exports = [
  id: "table"
  src: "images/table.png"
  x: 600
  y: 500
  onHit:
    # left, right, top, bottom, any -> 
    left: (item, options) ->
      alert 'you hit the left side of the table. +100 Gold'
    any: ->
      console.log 'you ran into the table. are you drunk?'
]