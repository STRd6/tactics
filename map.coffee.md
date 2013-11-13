Map
===
    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    {Grid} = require "./lib/util"
    Graph = require ".graph"

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

    module.exports = (I={}) ->
      Object.defaults I,
        background: "#222034"

      grid = Grid 32, 18, (x, y) ->
        if x is 12 and y >= 12 or y is 12 and x >= 12
          sprite: wallSprites.rand()
          lit: false
          unseen: true
          opaque: true
        else
          sprite: groundSprites[0].rand()
          lit: false
          unseen: true
          opaque: false

      duders = [
        {x: 11, y: 11, sprite: Resource.sprite("human")}
      ]
      duderAt = (x, y) ->
        duders.filter (duder) ->
          duder.x is x and duder.y is y
        .first()

      # TODO: Make each character have separate fov
      duders.forEach (duder) ->
        fov = new Shadowcasting(duder, 7)
        fov.tileAt = grid.get
  
        fov.calculate()

      render: (canvas) ->
        canvas.fill I.background

        grid.each ({sprite, lit, unseen}, x, y) ->
          if !unseen
            sprite.draw(canvas, x * 32, y * 32)
            if duder = duderAt(x, y)
              duder.sprite.draw(canvas, x * 32, y * 32)

            if !lit
              canvas.drawRect
                x: x * 32
                y: y * 32
                width: 32
                height: 32
                color: "rgba(0, 0, 0, 0.5)"

      moveDuder: (position) ->
        path = Graph.aStar
          initial: Point(duders.first())
          goal: position
          neighbors: (position) ->
            [Point(1, 0), Point(-1, 0), Point(0, 1), Point(0, -1)].map (direction) ->
              [position.add(direction), 1]
          heuristic: (a, b) ->
            p = b.subtract(a).abs()

            p.x + p.y # Manhattan distance

        if path
          path.forEach (position) ->
            fov = new Shadowcasting(position, 7)
            fov.tileAt = grid.get
      
            fov.calculate()
