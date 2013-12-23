Remote Server
=============

Multiplayer via sending game state over remote server.

    server = "ws://192.168.2.102:8080"

    module.exports = ->
      ws = new WebSocket(server)

      return ws
