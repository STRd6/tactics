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
      unseen: true
      opaque: true
      solid: true

    ground = ->
      sprite: groundSprites[0].rand()
      lit: false
      unseen: true
      opaque: false
      solid: false

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
        if x is 12 and y >= 12 or y is 12 and x >= 12
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
          sight: 13
      ]

      duders.forEach (duder) ->
        duder.tileAt = grid.get
        duder.updateFOV()

      duderAt = (x, y) ->
        duders.filter (duder) ->
          position = duder.position()
          position.x is x and position.y is y
        .first()

      render: (canvas) ->
        canvas.fill I.background

        grid.each ({sprite, lit, seen}, x, y) ->
          if seen
            sprite.draw(canvas, x * 32, y * 32)
            if duder = duderAt(x, y)
              duder.sprite().draw(canvas, x * 32, y * 32)

            if !lit
              canvas.drawRect
                x: x * 32
                y: y * 32
                width: 32
                height: 32
                color: "rgba(0, 0, 0, 0.5)"

      tileAt: grid.get

      moveDuder: (position) ->
        duder = duders.first()

        path = Graph.aStar
          initial: duder.position()
          goal: position
          neighbors: (position) ->
            # TODO: Add diagonals if both edges are passable
            moveDirections.map (direction) ->
              position.add(direction)
            .filter (position) ->
              tile = grid.get(position)
              tile and !tile.solid
            .map (position) ->
              [position, 1]
          heuristic: (a, b) ->
            p = b.subtract(a).abs()

            p.x + p.y # Manhattan distance

        if path
          path.forEach duder.updatePosition
