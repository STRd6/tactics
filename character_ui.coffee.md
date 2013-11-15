Character UI
============

Methods for drawing components of the character ui.

    Resource = require "./resource"
    {Size} = require "./lib/util"

    tileSize = Size(32, 32)

    heartSprite = Resource.sprite("heart")
    heartEmptySprite = Resource.sprite("heart_empty")
    actionBarSprite = Resource.sprite("action_bar")

    drawHealth = (canvas, health, max) ->
      max.times (i) ->
        x = i * 10
        if i < health
          heartSprite.draw(canvas, x, 0)
        else
          heartEmptySprite.draw(canvas, x, 0)

    drawActions = (canvas, n) ->
      n.times (i) ->
        actionBarSprite.draw canvas, i * 16 + 1, 32

    module.exports =

Draw the tactical overlay, indicating actions, health, max health.

      tactical: (canvas, character, color="blue") ->
        position = character.position()
        canvasPosition = position.scale(tileSize)

        canvas.withTransform Matrix.translation(canvasPosition.x, canvasPosition.y), (canvas) ->
          drawActions(canvas, character.actions())
          drawHealth(canvas, character.health(), character.healthMax())
