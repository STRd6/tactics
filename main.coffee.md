Tactics
=======

A game about squad based dungeon combat.

You manage a tribe of humble humanoids over a thousand years.

Will you conquer the world? Will they all die? That's between you and the RNG.

    # For debug purposes
    global.PACKAGE = PACKAGE
    global.require = require

    runtime = require("runtime")(PACKAGE)
    runtime.boot()
    runtime.applyStyleSheet(require('./style'))

    Canvas = require "touch-canvas"
    Sprite = require "./sprite"
    Action = require "./action"
    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    {Grid} = require "./lib/util"
    Geom = require "./lib/geom"

    {width, height} = require("./pixie")
    
    bgColor = "#222034"

    canvas = Canvas
      width: width
      height: height

    $("body").append canvas.element()

    canvas.fill bgColor

    allSprites = Object.keys(require("./images")).map (name) ->
      Sprite.load(Resource.load(name))

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        Sprite.load(Resource.load("#{type}#{i}"))

    bushSprites = [0..3].map (i)->
      Sprite.load(Resource.load("bush#{i}"))

    setTimeout ->
      allSprites.each (sprite, i) ->
        sprite.draw canvas, (i % 32) * 32, (i / 32).floor() * 32
    , 0

    ui =
      actions: Observable [
        Action
          name: "New Game"
          icon: Resource.load("new_game")
          perform: ->
            grid = Grid 32, 18, ->
              sprite: groundSprites[0].rand()
              lit: false
              unseen: true
              opaque: false

            canvas.fill bgColor

            fov = new Shadowcasting(Point(10, 10), 4)
            fov.tileAt = grid.get

            fov.calculate()

            fov.update Point(11, 11)

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

        Action
          name: "Tutorial"
          icon: Resource.load("book")
          perform: ->
            alert "Experience is the only teacher."
      ]

    $("body").append require("./templates/ui")(ui)
