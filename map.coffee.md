Map
===
    Sprite = require "./sprite"
    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    {Grid} = require "./lib/util"

Hold the terrain and whatnot for a level.

    allSprites = Object.keys(require("./images")).map (name) ->
      Sprite.load(Resource.load(name))

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        Sprite.load(Resource.load("#{type}#{i}"))

    bushSprites = [0..3].map (i)->
      Sprite.load(Resource.load("bush#{i}"))

    module.exports = (I={}) ->
      Object.defaults I,
        background: "#222034"

      grid = Grid 32, 18, (x, y) ->
        sprite: groundSprites[0].rand()
        lit: false
        unseen: true
        opaque: x is 12 and y is 12

      # TODO: Make each character have separate fov
      fov = new Shadowcasting(Point(10, 10), 7)
      fov.tileAt = grid.get

      fov.calculate()

      fov.update Point(11, 11)

      render: (canvas) ->
        canvas.fill I.background

        grid.each ({sprite, lit, unseen}, x, y) ->
          if lit
            sprite.draw(canvas, x * 32, y * 32)
          else if !unseen
            sprite.draw(canvas, x * 32, y * 32)
            canvas.drawRect
              x: x * 32
              y: y * 32
              width: 32
              height: 32
              color: "rgba(0, 0, 0, 0.5)"
    