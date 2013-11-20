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
          feature.draw canvas, 

    drawCharacters = (tiles, canvas) ->
      tiles.forEach ([_, position]) ->
        canvasPosition = position.scale(tileSize)

        if character = self.characterAt(x, y)
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

        render: (canvas) ->
          canvas.fill I.backgroundColor

          index = activeSquadIndex()
          seenTiles = self.seenTiles()
          
          drawGround(seenTiles, canvas)
          
          [litTiles, unlitTiles] = seenTiles.partition ([tile]) ->
            tile.lit[index]

          drawCharacters(litTiles, canvas)
          drawFeatures(seenTiles, canvas)
          drawFog(unlitTiles, canvas)
