Map Rendering
=============

Drawing the map data on the screen.

    CharacterUI = require "./character_ui"
    {Size, Bounds} = require "./lib/util"
    Resource = require "./resource"

    gridSprite = Resource.sprite("grid_blue")

Tile size in pixels.

    tileSize = Size(32, 32)
    inverseTileSize = Size(1/32, 1/32)
    viewportTileExtent = Size(32, 18)
    #TODO: Adjustable viewport size
    viewportSize = Point(1024, 568)

    # Quadratic in-out
    easing = (t) ->
      t *= 2
      if (t < 1)
        return 1/2 * t * t
      t--

      return -1/2 * (t*(t-2) - 1)

    module.exports = (I={}, self) ->

Rendering offset in pixels.

      offset = Point(0, 0)

      animationQueue = []

      screenPositions = [0...(self.width() * self.height())].map (i) ->
        x = i % self.width()
        y = (i / self.width()).floor()

        Point(x, y)

      drawGround = (canvas) ->
        index = self.activeSquadIndex()
        seen = self.seen.get(index)
        screenPositions.forEach (position) ->
          if self.isSeen(position)
            self.tileAt(position)?.draw canvas, position.scale(tileSize)

      drawFeatures = (canvas, under) ->
        # TODO: clipping?
        # TODO: Select only features in range from quad tree
        self.features().forEach (feature) ->
          position = feature.position()

          if self.isSeen(position) and feature.seen(self.activeSquadIndex())
            zIndex = feature.zIndex()
            if (under and zIndex <= 0) or (!under and zIndex > 0)
              feature.draw canvas, position.scale(tileSize)

      drawCharacters = (canvas, t) ->
        lit = self.lit.get(self.activeSquadIndex())
        self.characters().forEach (character) ->
          if character.alive()
            {x, y} = position = character.position()

            if lit.get(x + y * self.width())
              canvasPosition = character.position().scale(tileSize)

              character.sprite().draw(canvas, canvasPosition)

      drawFog = (canvas) ->
        screenPositions.forEach (position) ->
          if self.isSeen(position) and !self.isLit(position)
            bounds = Bounds(Point(position).scale(tileSize), tileSize)
            bounds.color = "rgba(0, 0, 0, 0.5)"

            canvas.drawRect(bounds)

      drawDebug = (canvas) ->
        if character = self.activeCharacter()
          if positions = character.debugPositions()
            positions.forEach (position) ->
              bounds = Bounds(Point(position).scale(tileSize), tileSize)
              bounds.color = "rgba(0, 255, 0, 0.5)"

              canvas.drawRect(bounds)

      backgroundColor = "#222034"

      self.activeCharacter.observe (character) ->
        if character
          self.animate
            position: character.position()

      scrollingAnimator = null

      self.extend
        transform: ->
          Matrix.translation(-offset.x, -offset.y)

        offset: ->
          offset

        animate: (event) ->
          animationQueue.push event

Scroll the camera to the given position. Duration in ms.

        scrollTo: (position, duration=300) ->
          clearInterval scrollingAnimator

          do (currentOffset=offset) ->
            startTime = +new Date
            target = position.scale(tileSize).subtract(viewportSize.scale(0.5))

            scrollingAnimator = setInterval ->
              t = ((+new Date) - startTime) / duration

              if t < 1
                offset = Point.interpolate(currentOffset, target, easing(t))
              else
                offset = target
                clearInterval scrollingAnimator
            , 15

Transforms position (a point from 0, 0 to 1, 1) into a tile position (from 0, 0
to self.width(), self.height())

        positionToTile: (position) ->
          position.scale(viewportTileExtent).add(offset.scale(inverseTileSize)).floor()

        render: (canvas, t) ->
          canvas.fill backgroundColor

          canvas.withTransform self.transform(), (canvas)->
            drawGround(canvas)

            # TODO: Iterate zSorted features + characters on a per chunk basis
            # TODO: Only draw seen features
            drawFeatures(canvas, true)
            drawCharacters(canvas, t)
            drawFeatures(canvas)

            drawFog(canvas)

            # drawDebug(canvas)

        renderUI: (canvas, t) ->
          canvas.clear()

          canvas.withTransform self.transform(), (canvas)->
            self.visibleCharacters().forEach (character) ->
              if character is self.activeCharacter()
                CharacterUI.activeTactical(canvas, character)
              else if character.alive()
                CharacterUI.tactical(canvas, character)

            self.accessiblePositions()?.forEach (position) ->
              gridSprite.draw canvas, position.scale(32)

        touch: (position) ->
          tilePosition = self.positionToTile(position)
          console.log tilePosition.x, tilePosition.y

          accessiblePositions = self.accessiblePositions()

          if accessiblePositions
            inRange = accessiblePositions.reduce (found, position) ->
              found or position.equal(tilePosition)
            , false

            if inRange
              self.selectTarget tilePosition
          else
            self.activeSquad().activateCharacterAt(tilePosition)

      # Kick off animation processing loop
      processAnimation = ->
        if event = animationQueue.shift()
          {message, position, duration} = event

          self.scrollTo position if position
          self.message message if message

          setTimeout processAnimation, (duration or 300)
        else
          setTimeout processAnimation, 15

      processAnimation()

      return self
