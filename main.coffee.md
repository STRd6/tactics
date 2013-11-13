Tactics
=======

A game about squad based dungeon combat.

You manage a tribe of humble humanoids over a thousand years.

Will you conquer the world? Will they all die? That's between you and the RNG.

    require "./setup"

    Canvas = require "touch-canvas"
    Action = require "./action"
    Resource = require "./resource"
    Map = require "./map"

    {Grid, Size} = require "./lib/util"
    Geom = require "./lib/geom"

    {width, height} = require("./pixie")

    tileExtent = Size 32, 18

    bgColor = "#222034"

    canvas = Canvas
      width: width
      height: height

    canvas.fill bgColor

    $("body").append canvas.element()

    ui =
      actions: Observable [
        Action
          name: "New Game"
          icon: Resource.dataURL("new_game")
          perform: ->
            map = Map()
            
            map.render(canvas)

        Action
          name: "Tutorial"
          icon: Resource.dataURL("book")
          perform: ->
            alert "Experience is the only teacher."
      ]

    $("body").append require("./templates/ui")(ui)

    uiCanvas = Canvas
      width: width
      height: height

    uiCanvas.on "touch", (position) ->
      map.moveDuder position.scale(tileExtent).floor()

    $(".ui").prepend uiCanvas.element()
