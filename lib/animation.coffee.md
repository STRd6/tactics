Animation
=========

    Resource = require "../resource"

    module.exports = (names) ->
      return undefined unless names

      draw: (canvas, canvasPosition, t) ->
        name = names.wrap(t | 0)
        Resource.sprite(name).draw(canvas, canvasPosition)
