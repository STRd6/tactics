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

    {Grid} = require "./lib/util"

    {width, height} = require("./pixie")

    canvas = Canvas
      width: width
      height: height

    $("body").append canvas.element()

    canvas.fill "#222034"

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        Sprite.load(Resource.load("#{type}#{i}"))

    setTimeout ->
      groundSprites.each (list, j) ->
        list.each (sprite, i) ->
          sprite.draw canvas, 2 + 36 * i, 2 + 36 * j
    , 0

    ui =
      actions: Observable [
        Action
          name: "New Game"
          icon: Resource.load("new_game")
          perform: ->
            grid = Grid 30, 10, ->
              groundSprites[0].rand()
            canvas.clear()
            grid.each (sprite, x, y) ->
              sprite.draw(canvas, x * 32, y * 32)
        Action
          name: "Tutorial"
          icon: Resource.load("book")
          perform: ->
            alert "Not a chance!"
      ]

    $("body").append require("./templates/ui")(ui)
