Map
===
    Ability = require "./ability"
    Resource = require "./resource"
    MapSearch = require "./map_search"
    Squad = require "./squad"

    {Grid} = require "./lib/util"
    Graph = require "./graph"

    {
      intersection
    } = require "./array_helpers"

    moveDirections = [
      Point(1, 0)
      Point(-1, 0)
      Point(0, 1)
      Point(0, -1)
    ]

Hold the terrain and whatnot for a level.

    global.allSprites = Object.keys(require("./images")).map Resource.sprite

    skeletonSprite = Resource.sprite "skeleton"

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        "#{type}#{i}"
      .map Resource.sprite

    bushSprites = [0..3].map (i)->
      Resource.sprite("bush#{i}")

    wallSprites = [0..3].map (i) ->
      Resource.sprite("brick_vines#{i}")

    wall = ->
      sprite: wallSprites.rand()
      lit: []
      seen: []
      opaque: true
      solid: true
      features: []

    ground = ->
      bush = rand() < 0.1

      sprite: groundSprites[0].rand()
      lit: []
      seen: []
      opaque: bush
      solid: false
      features: [0...bush].map ->
        bushSprites.rand()

    module.exports = (I={}) ->
      Object.defaults I,
        background: "#222034"

      grid = Grid 32, 18, (x, y) ->
        if rand() < 0.10
          wall()
        else
          ground()

      tileAt = grid.get

      updateVisibleTiles = ->
        grid.each (tile) ->
          tile.lit = []

        squads.forEach (squad, i) ->
          squad.characters().filter (character) ->
            character.alive()
          .forEach (duder) ->
            duder.visiblePositions(tileAt).map(tileAt).forEach (tile) ->
              tile.seen[i] = tile.lit[i] = true

      squads = [
        Squad()
        Squad
          sprite: "goblin"
          x: 30
      ]

      activeSquad = Observable squads.first()
      activeSquadIndex = ->
        squads.indexOf activeSquad()

      nextActivatableSquad = ->
        squads.filter (squad) ->
          squad.activeCharacter()
        .first()

      characterAt = (x, y) ->
        if x.x?
          {x, y} = x

        self.characters().filter (character) ->
          position = character.position()
          position.x is x and position.y is y
        .first()

      search = MapSearch(grid.get, characterAt)

      self =
        characters: Observable ->
          squads.map (squad) ->
            squad.characters()
          .flatten()

        visibleCharacters: ->
          index = activeSquadIndex()
          self.characters().filter (character) ->
            tileAt(character.position()).lit[index]

        render: (canvas) ->
          canvas.fill I.background

          grid.each (tile, x, y) ->
            {sprite, lit, seen} = tile
            canvasPosition = Point(x, y).scale(32)
            
            index = activeSquadIndex()

            if seen[index]
              sprite.draw(canvas, canvasPosition)

              if lit[index]
                if duder = characterAt(x, y)
                  if duder.alive()
                    duder.sprite().draw(canvas, canvasPosition)
                  else
                    skeletonSprite.draw(canvas, canvasPosition)

              tile.features.forEach (feature) ->
                feature.draw(canvas, canvasPosition)

              if !lit[index]
                # Draw fog of war
                canvas.drawRect
                  x: x * 32
                  y: y * 32
                  width: 32
                  height: 32
                  color: "rgba(0, 0, 0, 0.5)"

        activeCharacter: Observable ->
          # Dependencies for observable
          squads.forEach (squad) ->
            squad.activeCharacter()

          activeSquad()?.activeCharacter()

        targettingAbility: ->
          if character = self.activeCharacter()
            character.targettingAbility()

        accessiblePositions: ->
          duder = self.activeCharacter()

          if ability = self.targettingAbility()
            switch ability.targetZone()
              when Ability.TARGET_ZONE.SELF
                self.performAbility(duder, ability, duder.position())

                return
              when Ability.TARGET_ZONE.MOVEMENT
                search.accessible(duder, duder.movement(), activeSquadIndex())
              when Ability.TARGET_ZONE.LINE_OF_SIGHT
                visiblePositions = duder.visiblePositions(tileAt)
                positionsInRange = search.adjacent(duder, ability.range())

                intersection (
                  visiblePositions
                  #positionsInRange
                )

        stateBasedActions: ->
          squads.forEach (squad) ->
            squad.stateBasedActions()

          activeSquad nextActivatableSquad()

          unless self.activeCharacter()
            # Refresh all squads
            squads.forEach (squad) ->
              squad.ready()

            activeSquad nextActivatableSquad()

            unless activeSquad()
              ;# No survivors

        performAbility: (owner, ability, targetPosition) ->
          ability.perform owner,
            position: targetPosition
            character: characterAt targetPosition

          self.stateBasedActions()

        selectTarget: (position) ->
          ability = self.targettingAbility()

          switch ability.targetZone()
            when Ability.TARGET_ZONE.MOVEMENT
              self.moveDuder(position)
            else
              self.performAbility(self.activeCharacter(), ability, position)

        touch: (position) ->
          activeSquad()?.activateCharacterAt(position)

        moveDuder: (position) ->
          duder = self.activeCharacter()

          path = search.movementPath(duder, position, activeSquadIndex())

          if path
            index = activeSquadIndex()

            path.forEach (position) ->
              duder.visiblePositions(tileAt).map(tileAt).forEach (tile) ->
                tile.seen[index] = true

            self.performAbility(duder, self.targettingAbility(), position)

          updateVisibleTiles()

      updateVisibleTiles()

      return self
