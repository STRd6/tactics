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

    {width, height} = require("./pixie")

    canvas = Canvas
      width: width
      height: height

    $("body").append canvas.element()
    
    canvas.fill "red"

    ui =
      actions: Observable [Action(), Action()]

    $("body").append require("./templates/ui")(ui)
