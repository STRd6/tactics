Map
===
    Resource = require "./resource"
    Duder = require "./duder"

    {Grid} = require "./lib/util"
    Graph = require "./graph"

Hold the terrain and whatnot for a level.

    global.allSprites = Object.keys(require("./images")).map Resource.sprite

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        "#{type}#{i}"
      .map Resource.sprite

    bushSprites = [0..3].map (i)->
      Resource.sprite("bush#{i}")

    wallSprites = [0..3].map (i) ->
      Resource.sprite("brick_vines#{i}")

    wall = ->
      sprite: wallSprites.rand()
      lit: false
      seen: false
      opaque: true
      solid: true
      features: []

    ground = ->
      bush = rand() < 0.1

      sprite: groundSprites[0].rand()
      lit: false
      seen: false
      opaque: bush
      solid: false
      features: [0...bush].map ->
        bushSprites.rand()

    moveDirections = [
      Point(1, 0)
      Point(-1, 0)
      Point(0, 1)
      Point(0, -1)
    ]

    module.exports = (I={}) ->
      Object.defaults I,
        background: "#222034"

      grid = Grid 32, 18, (x, y) ->
        if (x is 12 and y >= 12 or y is 12 and x >= 12)
          if (x is 20 and y is 12)
            ground()
          else
            wall()
        else
          if rand() < 0.10
            wall()
          else
            ground()

      neighbors = (position) ->
        # TODO: Add diagonals if both edges are passable
        moveDirections.map (direction) ->
          position.add(direction)
        .filter (position) ->
          tile = grid.get(position)
          tile and !tile.solid
        .filter ({x, y}) ->
          !duderAt(x, y)
        .map (position) ->
          [position, 1]

      neighborsVisible = (position) ->
        # TODO: Add diagonals if both edges are passable
        moveDirections.map (direction) ->
          position.add(direction)
        .filter (position) ->
          tile = grid.get(position)
          tile and !tile.solid and tile.lit
        .filter ({x, y}) ->
          !duderAt(x, y)
        .map (position) ->
          [position, 1]

      duders = [
        Duder
          position:
            x: 11
            y: 11
          sprite: "human"
          sight: 7
        Duder
          position:
            x: 20
            y: 15
          sprite: "goblin"
          sight: 7
      ]
      activeDuderIndex = 0

      duders.forEach (duder) ->
        duder.tileAt = grid.get

      updateVisibleTiles = ->
        grid.each (tile) ->
          tile.lit = false

        duders.forEach (duder) ->
          duder.visibleTiles().forEach (tile) ->
            tile.seen = tile.lit = true

      duderAt = (x, y) ->
        duders.filter (duder) ->
          position = duder.position()
          position.x is x and position.y is y
        .first()

      updateVisibleTiles()

      self =
        render: (canvas) ->
          canvas.fill I.background

          grid.each (tile, x, y) ->
            {sprite, lit, seen} = tile
            canvasPosition = Point(x, y).scale(32)

            if seen
              sprite.draw(canvas, canvasPosition)
              if duder = duderAt(x, y)
                duder.sprite().draw(canvas, canvasPosition)

              tile.features.forEach (feature) ->
                feature.draw(canvas, canvasPosition)

              if !lit
                canvas.drawRect
                  x: x * 32
                  y: y * 32
                  width: 32
                  height: 32
                  color: "rgba(0, 0, 0, 0.5)"

        tileAt: grid.get

        activeDuder: ->
          duders.wrap(activeDuderIndex)

        accessiblePositions: ->
          duder = self.activeDuder()

          Graph.accessible
            initial: duder.position()
            neighbors: neighborsVisible
            distanceMax: duder.movement()

        updateDuder: ->
          duder = self.activeDuder()

          if duder.actions() is 0
            activeDuderIndex += 1

            # TODO: Maybe move this into a separate ready step for each squad
            duder.ready()

        moveDuder: (position) ->
          duder = self.activeDuder()

          path = Graph.aStar
            initial: duder.position()
            goal: position
            neighbors: neighborsVisible
            heuristic: (a, b) ->
              p = b.subtract(a).abs()

              p.x + p.y # Manhattan distance

          if path
            path.forEach (position) ->
              duder.updatePosition position
              duder.visibleTiles().forEach (tile) ->
                tile.seen = true

            duder.move path.last()

            self.updateDuder()

          updateVisibleTiles()

      return self
