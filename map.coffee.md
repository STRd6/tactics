Map
===

The primary tactical combat screen.

    Ability = require "./ability"
    Graph = require "./graph"
    MapGenerator = require "./map_generator"
    MapSearch = require "./map_search"
    Squad = require "./squad"

    {
      intersection
    } = require "./array_helpers"

    module.exports = (I={}, self) ->
      self ?= Core(I)

      I.currentTurn = 0

      grid = MapGenerator.generate
        width: 32
        height: 18

      tileAt = grid.get

      # TODO: Add trap detection
      # TODO: Keep track of seen features as well as seen tiles
      viewTiles = (positions, index) ->
        positions.map(tileAt).forEach (tile) ->
          tile?.view index

      updateVisibleTiles = ->
        grid.each (tile) ->
          tile.resetLit()

        squads.forEach (squad, i) ->
          squad.characters().filter (character) ->
            character.alive()
          .forEach (duder) ->
            # Magical vision
            viewTiles duder.magicalVision(), i

            # Physical sensing
            viewTiles search.adjacent(duder.position()), i

            # Normal Sight
            viewTiles search.visible(duder.position(), duder.sight()), i

      squads = [
        Squad()
        Squad
          race: "goblin"
          x: 30
      ]

      activeSquad = Observable squads.first()

      nextActivatableSquad = ->
        squads.filter (squad) ->
          squad.activeCharacter()
        .first()

      characterPassable = (character) ->
        (position) ->
          if tile = tileAt(position)
            if occupant = characterAt(position)
              occupantPassable = (activeSquad().characters.indexOf(occupant) != -1)
            else
              occupantPassable = true

            !tile.impassable() and tile.lit(self.activeSquadIndex()) and occupantPassable

      characterAt = (x, y) ->
        if x.x?
          {x, y} = x

        self.characters().filter (character) ->
          position = character.position()
          character.alive() and (position.x is x and position.y is y)
        .first()

      search = MapSearch(grid.get, characterAt)

      effectStack = []
      featuresToAdd = []

      self.include require("./map_serialization")

      Object.extend self,
        messages: Observable []

        tiles: grid

        activeSquadIndex: ->
          squads.indexOf activeSquad()

        characters: Observable ->
          squads.map (squad) ->
            squad.characters()
          .flatten()

        characterAt: characterAt

        eachTile: grid.each

        visibleCharacters: ->
          index = self.activeSquadIndex()
          self.characters().filter (character) ->
            tileAt(character.position()).lit(index)

        activeCharacter: Observable ->
          # Dependencies for observable
          squads.forEach (squad) ->
            squad.activeCharacter()

          activeSquad()?.activeCharacter()

        updateFeatures: ->
          grid.each (tile, position) ->
            tile.updateFeatures
              addEffect: self.addEffect
              characterAt: characterAt
              message: self.message
              tileAt: tileAt
              position: position
              turn: I.currentTurn
              addFeature: self.addFeature

        targettingAbility: ->
          if character = self.activeCharacter()
            character.targettingAbility()

        accessiblePositions: ->
          character = self.activeCharacter()

          if ability = self.targettingAbility()
            switch ability.targetZone()
              when Ability.TARGET_ZONE.SELF
                self.performAbility(character, ability, character.position())

                return
              when Ability.TARGET_ZONE.MOVEMENT
                accessiblePositions = search.accessible(character.position(), character.movement(), characterPassable(character))

                accessiblePositions.reject (position) ->
                  characterAt(position)

              when Ability.TARGET_ZONE.ANY
                positionsInRange = search.adjacent(character.position(), ability.range())

              when Ability.TARGET_ZONE.LINE_OF_SIGHT
                visiblePositions = search.visible(character.position(), character.sight())
                positionsInRange = search.adjacent(character.position(), ability.range())

                intersection(
                  visiblePositions
                  positionsInRange
                )

        stateBasedActions: ->
          squads.forEach (squad) ->
            squad.stateBasedActions
              addEffect: self.addEffect

          while effectStack.length
            # TODO: This could fall victim to infinite recursion
            self.performEffect effectStack.pop()

          while featuresToAdd.length
            [feature, position] = featuresToAdd.pop()

            tileAt(position)?.features.push(feature)

          # TODO: May be able to consolidate these into the stack resolution
          activeSquad nextActivatableSquad()

          updateVisibleTiles()

          unless self.activeCharacter()
            # End of Round
            self.ready()

        ready: ->
          I.currentTurn += 1
          self.updateFeatures()

          # Refresh all squads
          squads.forEach (squad) ->
            squad.ready()

          activeSquad nextActivatableSquad()

          if activeSquad()
            self.stateBasedActions()
          else
            ;# No survivors

        message: (message) ->
          self.messages.push message + "\n"

        addEffect: (effect) ->
          effectStack.push effect

        addFeature: (feature, position) ->
          feature.I.createdAt = I.currentTurn
          featuresToAdd.push([feature, position])

        performAbility: (owner, ability, targetPosition) ->
          ability.perform
            owner: owner
            addEffect: self.addEffect
            character: characterAt targetPosition
            message: self.message
            position: targetPosition
            addFeature: self.addFeature

          self.stateBasedActions()

        performEffect: (effect) ->
          effect.perform
            addEffect: self.addEffect
            characterAt: characterAt
            message: self.message
            tileAt: tileAt
            addFeature: self.addFeature

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
          character = self.activeCharacter()

          path = search.movementPath(
            character.position(),
            position,
            characterPassable(character)
          )

          if path
            index = self.activeSquadIndex()
            # TODO: Maybe this should be done as SBAs
            path.forEach (position) ->
              viewTiles search.visible(character.position(), character.sight()), index

            self.performAbility(character, self.targettingAbility(), position)

      updateVisibleTiles()

      self.include require("./map_rendering")

      return self
