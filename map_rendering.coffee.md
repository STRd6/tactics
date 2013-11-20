Map Rendering
=============

Drawing the map data on the screen.

    module.exports = (I={}, self) ->
      I.backgroundColor ?= "#222034"

      Object.extend self,
        render: (canvas) ->
          canvas.fill I.backgroundColor

          self.eachTile (tile, x, y) ->
            {sprite, lit, seen} = tile
            canvasPosition = Point(x, y).scale(32)

            index = self.activeSquadIndex()

            if seen[index]
              sprite.draw(canvas, canvasPosition)

              if lit[index]
                if duder = self.characterAt(x, y)
                  if duder.alive()
                    duder.sprite().draw(canvas, canvasPosition)
                  else
                    skeletonSprite.draw(canvas, canvasPosition)

              tile.features.forEach (feature) ->
                feature.draw(canvas, canvasPosition)

              if !lit[index]
                # Draw fog of war
                canvas.drawRect
                  x: x * 32
                  y: y * 32
                  width: 32
                  height: 32
                  color: "rgba(0, 0, 0, 0.5)"
