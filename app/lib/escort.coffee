channel_prefix = "players_"

module.exports =
  capacity: 10
  findEmptyRoom: (PN, cb) ->
    @testRoom(PN, 0, cb)

  testRoom: (PN, i, cb) ->
    PN.here_now
      channel : channel_prefix + i
      callback : (m) =>
        if m.uuids.length >= @capacity
          @testRoom(PN, i+1, cb)
        else
          cb(channel_prefix + i)
