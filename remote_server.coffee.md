Remote Server
=============

Multiplayer via sending game state over remote server.

    server = "ws://thawing-mesa-4646.herokuapp.com"

    module.exports = ->
      ws = new WebSocket(server)

      return ws
