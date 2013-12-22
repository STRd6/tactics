Tactics
=======

A game about squad based dungeon combat.

You manage a tribe of humble humanoids over a thousand years.

Will you conquer the world? Will they all die? That's between you and the RNG.

    require "./setup"

    Canvas = require "touch-canvas"
    CharacterUI = require "./character_ui"
    Action = require "./action"
    Map = require "./map"
    Resource = require "./resource"
    Resource.addSource("7ffbdcf587f407dda0d6")

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

    # TODO: Add actions for between rounds
    # TODO: Add conditional cancel action
    updateActions = (character) ->
      if character
        ui.actions CharacterUI.actions(character)
      else
        ui.actions []

    updateCharacters = (characters) ->
      if characters
        ui.characters characters.copy().reverse()
      else
        ui.characters []

    checkForWinner = ->
      if map.squads()[0].characters().filter((c) -> c.alive()).length is 0
        $(".winner").text("#{map.squads()[1].I.race} squad wins!")
        $(".winner_container").show()
      else if map.squads()[1].characters().filter((c) -> c.alive()).length is 0
        $(".winner").text("#{map.squads()[0].I.race} squad wins!")
        $(".winner_container").show()

    ui =
      characters: Observable []
      messages: Observable [
        "Welcome to the arena!\n"
      ]
      actions: Observable [
        Action
          name: "New Game"
          description: "Start a new battle."
          icon: "new_game"
          perform: ->
            # HACK hide the name of the game
            $(".title").hide()

            global.map = map = Map()
            map.messages.observe (messages) ->
              ui.messages(messages.copy())

            map.activeCharacter.observe updateActions

            update()
      ]
      actionPerformed: ->
        update()

    $("body").append require("./templates/ui")(ui)

    accessiblePositions = null

    update = ->
      if map
        updateActions(map.activeCharacter())
        updateCharacters(map.activeSquad().characters())
        accessiblePositions = map.accessiblePositions()
        checkForWinner()

    t = 0
    setInterval ->
      t += (1 / 30)

      map?.render(canvas, t)
      map?.renderUI(uiCanvas, t)
    , 33.3333333

    uiCanvas = Canvas
      width: width
      height: height

    uiCanvas.on "touch", (position) ->
      map?.touch position
      update()

    $(".ui").prepend uiCanvas.element()
