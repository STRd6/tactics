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
    CharacterUI = require "./character_ui"

    {Grid, Size} = require "./lib/util"
    Geom = require "./lib/geom"

    {width, height} = require("./pixie")

    tileExtent = Size 32, 18

    bgColor = "#222034"

    global.canvas = canvas = Canvas
      width: width
      height: height

    canvas.fill bgColor

    $("body").append canvas.element()

    global.map = map = null

    ui =
      actions: Observable [
        Action
          name: "New Game"
          icon: Resource.dataURL("new_game")
          perform: ->
            global.map = map = Map()
            update()

        Action
          name: "Tutorial"
          icon: Resource.dataURL("book")
          perform: ->
            alert "Experience is the only teacher."
      ]

    $("body").append require("./templates/ui")(ui)

    accessiblePositions = null
    activeCharacter = null
    update = ->
      map.render(canvas)
      accessiblePositions = map.accessiblePositions()
      activeCharacter = map.activeDuder()
      updateUiCanvas()

    uiCanvas = Canvas
      width: width
      height: height

    uiCanvas.on "touch", (position) ->
      tilePosition = position.scale(tileExtent).floor()

      inRange = accessiblePositions.reduce (found, position) ->
        found or position.equal(tilePosition)
      , false

      if inRange
        map.moveDuder tilePosition
        update()      

    updateUiCanvas = ->
      uiCanvas.clear()

      if accessiblePositions
        accessiblePositions.forEach (position) ->
          uiCanvas.drawRect
            stroke:
              color: "#00F"
            position: position.scale(32)
            width: 32
            height: 32

      if activeCharacter
        CharacterUI.tactical(uiCanvas, activeCharacter)

    $(".ui").prepend uiCanvas.element()
