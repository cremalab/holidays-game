View     = require './view'

module.exports = class DJ extends View
  audio: {}
  currentTrack: 'soundtrack'
  isPlaying: false
  tracks:
    'soundtrack': 'https://s3.amazonaws.com/cremalab/bit-shifter-let-it-snow.mp3'
    'disco'     : 'https://s3.amazonaws.com/cremalab/disco.mp3'

  initialize: ->
    for track in Object.keys @tracks
      @audio[track] = new Audio(@tracks[track])
      @audio[track].loop = true
    @playTrack(@currentTrack)

  playTrack: (track) ->
    @audio[@currentTrack].pause()
    unless @isPlaying is false
      @audio[track].play()
    @currentTrack = track

  togglePlayback: ->
    if @isPlaying
      @audio[@currentTrack].pause()
      @isPlaying = false
    else
      @audio[@currentTrack].play()
      @isPlaying = true
