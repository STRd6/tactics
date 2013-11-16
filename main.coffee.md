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
      messages: Observable [
        "Hello\n"
      ]
      actions: Observable [
        Action
          name: "New Game"
          icon: "new_game"
          perform: ->
            global.map = map = Map()
            update()

        Action
          name: "Tutorial"
          icon: "book"
          perform: ->
            alert "Experience is the only teacher."
      ]
      actionPerformed: ->
        update()

    $("body").append require("./templates/ui")(ui)

    accessiblePositions = null
    activeCharacter = null

    update = ->
      if map
        map.stateBasedActions()
        map.render(canvas)
        accessiblePositions = map.accessiblePositions()
        activeCharacter = map.activeCharacter()
        updateUiCanvas()
        ui.actions activeCharacter.uiActions()

    uiCanvas = Canvas
      width: width
      height: height

    uiCanvas.on "touch", (position) ->
      tilePosition = position.scale(tileExtent).floor()

      if accessiblePositions
        inRange = accessiblePositions.reduce (found, position) ->
          found or position.equal(tilePosition)
        , false

        if inRange
          map.selectTarget tilePosition
          update()

    gridSprite = Resource.sprite("grid_blue")

    updateUiCanvas = ->
      uiCanvas.clear()

      if map
        map.characters().forEach (duder) ->
          if duder is activeCharacter
            CharacterUI.activeTactical(uiCanvas, duder)
          else
            CharacterUI.tactical(uiCanvas, duder)

        if accessiblePositions
          accessiblePositions.forEach (position) ->
            gridSprite.draw uiCanvas, position.scale(32)

    $(".ui").prepend uiCanvas.element()
