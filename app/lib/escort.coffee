channel_prefix = "players_"

module.exports = 
  findEmptyRoom: (PN) ->
    @testRoom()

  testRoom: (i) ->
    PN.here_now
      channel : channel_prefix + i,
      callback : function(m){console.log(m)}
