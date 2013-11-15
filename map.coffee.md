Map
===
    Ability = require "./ability"
    Resource = require "./resource"
    Duder = require "./duder"
    MapSearch = require "./map_search"

    {Grid} = require "./lib/util"
    Graph = require "./graph"

    moveDirections = [
      Point(1, 0)
      Point(-1, 0)
      Point(0, 1)
      Point(0, -1)
    ]

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
        if x.x?
          {x, y} = x

        duders.filter (duder) ->
          position = duder.position()
          position.x is x and position.y is y
        .first()

      updateVisibleTiles()

      search = MapSearch(grid.get, duderAt)

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

        activeDuder: ->
          duders.wrap(activeDuderIndex)

        accessiblePositions: ->
          duder = self.activeDuder()

          if ability = duder.targettingAbility()
            if ability.targetType() is Ability.TARGET_TYPE.SELF
              ability.perform duder,
                position: duder.position()
                character: duder

              duder.resetTargetting()
              self.updateDuder()

              return
            else if ability.targetType() is Ability.TARGET_TYPE.MOVEMENT
              search.accessible(duder)
            else if ability.targetType() is Ability.TARGET_TYPE.LOS
              # TODO: Real LOS not these mad hacks
              search.accessible(duder, 1)

        updateDuder: ->
          duder = self.activeDuder()

          if duder.actions() is 0
            activeDuderIndex += 1

            # TODO: Maybe move this into a separate ready step for each squad
            duder.ready()

        moveDuder: (position) ->
          duder = self.activeDuder()

          path = search.movementPath(duder, position)

          if path
            path.forEach (position) ->
              duder.updatePosition position
              duder.visibleTiles().forEach (tile) ->
                tile.seen = true

            duder.move path.last()

            duder.resetTargetting()
            self.updateDuder()

          updateVisibleTiles()

      return self
