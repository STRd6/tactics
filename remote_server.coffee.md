Remote Server
=============

Multiplayer via sending game state over remote server.

    ReconnectingWebSocket = require "./lib/reconnecting_websocket"
    server = "ws://thawing-mesa-4646.herokuapp.com"

    module.exports = ->
      ws = new ReconnectingWebSocket(server)

      return ws
