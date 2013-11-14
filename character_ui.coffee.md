Character UI
============

Methods for drawing components of the character ui.

    {Size} = require "./lib/util"

    tileSize = Size(32, 32)

    drawActions = (canvas, n) ->
      n.times (i) ->
        canvas.drawRect
          x: i * 16 + 1
          y: 32
          width: 14
          height: 4
          color: "blue"
          stroke:
            width: 1
            color: "white"

    module.exports =

Draw the tactical overlay, indicating actions, health, max health.

      tactical: (canvas, character, color="blue") ->
        position = character.position()
        canvasPosition = position.scale(tileSize)
        
        console.log canvasPosition

        canvas.withTransform Matrix.translation(canvasPosition.x, canvasPosition.y), (canvas) ->
          drawActions(canvas, character.actions())
