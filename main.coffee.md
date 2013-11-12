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
    Geom = require "./lib/geom"

    {width, height} = require("./pixie")
    
    bgColor = "#222034"

    canvas = Canvas
      width: width
      height: height

    $("body").append canvas.element()

    canvas.fill bgColor

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        Sprite.load(Resource.load("#{type}#{i}"))

    bushSprites = [0..3].map (i)->
      Sprite.load(Resource.load("bush#{i}"))

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
            grid = Grid 32, 18, ->
              groundSprites[0].rand()

            canvas.fill bgColor

            grid.each (sprite, x, y) ->
              sprite.draw(canvas, x * 32, y * 32)
            
            Geom.line Point(0, 0), Point(3, 5), ({x, y}) ->
              sprite = bushSprites.rand()
              sprite.draw(canvas, x * 32, y * 32)
              
            Geom.circle Point(15, 5), 7, ({x, y}) ->
              sprite = bushSprites.rand()
              sprite.draw(canvas, x * 32, y * 32)

        Action
          name: "Tutorial"
          icon: Resource.load("book")
          perform: ->
            alert "Not a chance!"
      ]

    $("body").append require("./templates/ui")(ui)
