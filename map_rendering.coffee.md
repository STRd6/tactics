Map Rendering
=============

Drawing the map data on the screen.

    {Size, Bounds} = require "./lib/util"
    Resource = require "./resource"

    skeleton = Resource.sprite "skeleton"

    tileSize = Size(32, 32)
    
    drawGround = (tiles, canvas) ->
      tiles.forEach ([{sprite}, position]) ->
        sprite.draw canvas, position.scale(tileSize)
    
    drawFeatures = (tiles, canvas) ->
      tiles.forEach ([{features}, position]) ->
        features.forEach (feature) ->
          feature.draw canvas, position.scale(tileSize)

    drawCharacters = (tiles, characterAt, canvas, t) ->
      tiles.forEach ([_, position]) ->
        bounce = Point(Math.cos(Math.TAU * t / 12), 0).scale(3).floor()
        canvasPosition = position.scale(tileSize).add(bounce)

        if character = characterAt(position)
          if character.alive()
            character.sprite().draw(canvas, canvasPosition)
          else
            skeletonSprite.draw(canvas, canvasPosition)

    drawFog = (tiles, canvas) ->
      tiles.forEach ([_, position]) ->
        bounds = Bounds(position.scale(tileSize), tileSize)
        bounds.color = "rgba(0, 0, 0, 0.5)"

        canvas.drawRect(bounds)

    module.exports = (I={}, self) ->
      I.backgroundColor ?= "#222034"

      Object.extend self,
        # TODO: Grid#filter
        seenTiles: (index) ->
          results = []

          self.eachTile (tile, position) ->
            results.push [tile, position] if tile.seen[index]

          results

        render: (canvas, t) ->
          canvas.fill I.backgroundColor

          index = self.activeSquadIndex()
          seenTiles = self.seenTiles(index)
          
          drawGround(seenTiles, canvas)
          
          [litTiles, unlitTiles] = seenTiles.partition ([tile]) ->
            tile.lit[index]

          drawCharacters(litTiles, self.characterAt, canvas, t)
          drawFeatures(seenTiles, canvas)
          drawFog(unlitTiles, canvas)
