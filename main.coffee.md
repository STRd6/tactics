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
    Map = require "./map"

    {Grid} = require "./lib/util"
    Geom = require "./lib/geom"

    {width, height} = require("./pixie")
    
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
          icon: Resource.load("new_game")
          perform: ->
            map = Map()
            
            map.render(canvas)

        Action
          name: "Tutorial"
          icon: Resource.load("book")
          perform: ->
            alert "Experience is the only teacher."
      ]

    $("body").append require("./templates/ui")(ui)
