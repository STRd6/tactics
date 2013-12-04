Map Rendering
=============

Drawing the map data on the screen.

    CharacterUI = require "./character_ui"
    {Size, Bounds} = require "./lib/util"
    Resource = require "./resource"

    gridSprite = Resource.sprite("grid_blue")

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
        [0...(self.width() * self.height())].forEach (i) ->
          x = i % self.width()
          y = (i / self.width()).floor()

          if self.isSeen(x, y) and !self.isLit(x, y)
            bounds = Bounds(Point(x, y).scale(tileSize), tileSize)
            bounds.color = "rgba(0, 0, 0, 0.5)"

            canvas.drawRect(bounds)

      backgroundColor = "#222034"

      self.extend
        render: (canvas, t) ->
          canvas.fill backgroundColor

          drawGround(canvas)

          # TODO: Iterate zSorted features + characters on a per chunk basis
          # TODO: Only draw seen features
          drawFeatures(canvas, true)
          drawCharacters(canvas, t)
          drawFeatures(canvas)

          drawFog(canvas)

        renderUI: (canvas, t) ->
          canvas.clear()

          self.visibleCharacters().forEach (character) ->
            if character is self.activeCharacter()
              CharacterUI.activeTactical(canvas, character)
            else
              CharacterUI.tactical(canvas, character)

          self.accessiblePositions()?.forEach (position) ->
            gridSprite.draw canvas, position.scale(32)
