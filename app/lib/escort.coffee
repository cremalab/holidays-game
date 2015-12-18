channel_prefix = "players_"

# Escorts players to a room with capacity

module.exports =
  capacity: 50
  findEmptyRoom: (PN, room, cb) ->
    room = room or ""
    @testRoom(PN, room, 1, cb)

  testRoom: (PN, room, i, cb) ->
    PN.here_now
      channel : channel_prefix + room + i
      callback : (m) =>
        if m.uuids.length >= @capacity
          @testRoom(PN, i+1, cb)
        else
          cb(channel_prefix + room + i)
