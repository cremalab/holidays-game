module.exports = [
  id: "bar"
  src: "images/bar.svg"
  x: 500
  y: 300
  onHit:
    # left, right, top, bottom, any -> 
    left: (item, options) ->
      alert 'you hit the left side of the table. +100 Gold'
    any: ->
      console.log 'you ran into the table. are you drunk?'
]