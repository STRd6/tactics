Map Rendering
=============

Drawing the map data on the screen.

    {Size, Bounds} = require "./lib/util"

    tileSize = Size(32, 32)

    module.exports = (I={}, self) ->
      drawGround = (canvas) ->
        index = self.activeSquadIndex()
        seen = self.seen.get(index)
        [0...(self.width() * self.height())].forEach (i) ->
          if seen.get(i)
            x = i % self.width()
            y = (i / self.width()).floor()

            self.tileAt(x, y).draw canvas, Point(x, y).scale(tileSize)

      drawFeatures = (canvas, under) ->
        self.features().forEach (feature) ->
          zIndex = feature.zIndex()
          if (under and zIndex <= 0) or (!under and zIndex > 0)
            feature.draw canvas, feature.position().scale(tileSize)
  
      drawCharacters = (canvas, t) ->
        lit = self.lit.get(self.activeSquadIndex())
        self.characters().forEach (character) ->
          {x, y} = position = character.position()

          if lit.get(x + y * self.width())
            canvasPosition = character.position().scale(tileSize)
  
            character.sprite().draw(canvas, canvasPosition)

      drawFog = (canvas) ->
        # TODO
        [].forEach ([_, position]) ->
          bounds = Bounds(position.scale(tileSize), tileSize)
          bounds.color = "rgba(0, 0, 0, 0.5)"
  
          canvas.drawRect(bounds)

      backgroundColor = "#222034"

      self.extend
        # TODO: Grid#filter
        seenTiles: (index) ->
          results = []

          self.eachTile (tile, position) ->
            results.push [tile, position] if tile.seen(index)

          results

        render: (canvas, t) ->
          canvas.fill backgroundColor

          index = self.activeSquadIndex()
          seenTiles = self.seenTiles(index)

          drawGround(canvas)

          # TODO: Iterate zSorted features + characters on a per chunk basis
          # TODO: Only draw seen features
          drawFeatures(canvas, true)
          drawCharacters(canvas, t)
          drawFeatures(canvas)

          drawFog(canvas)
