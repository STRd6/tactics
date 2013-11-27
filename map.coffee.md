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

      grid = MapGenerator.generate
        width: 32
        height: 18

      tileAt = grid.get

      updateVisibleTiles = ->
        grid.each (tile) ->
          tile.lit = []

        squads.forEach (squad, i) ->
          squad.characters().filter (character) ->
            character.alive()
          .forEach (duder) ->
            search.visible(duder.position(), duder.sight()).map(tileAt).forEach (tile) ->
              tile.seen[i] = tile.lit[i] = true

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

            !tile.solid and tile.lit[self.activeSquadIndex()] and occupantPassable

      characterAt = (x, y) ->
        if x.x?
          {x, y} = x

        self.characters().filter (character) ->
          position = character.position()
          character.alive() and (position.x is x and position.y is y)
        .first()

      search = MapSearch(grid.get, characterAt)

      Object.extend self,
        messages: Observable []
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
            tileAt(character.position()).lit[index]

        activeCharacter: Observable ->
          # Dependencies for observable
          squads.forEach (squad) ->
            squad.activeCharacter()

          activeSquad()?.activeCharacter()

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

              when Ability.TARGET_ZONE.LINE_OF_SIGHT
                visiblePositions = search.visible(character.position(), character.sight())
                positionsInRange = search.adjacent(character.position(), ability.range())

                intersection(
                  visiblePositions
                  positionsInRange
                )

        stateBasedActions: (n=16) ->
          stack = []

          squads.forEach (squad) ->
            squad.stateBasedActions(stack)

          if stack.length
            stack.map self.performEffect

            # Prevent infinite recursion
            if n > 0
              self.stateBasedActions(n-1)
            else
              console.warn "State Based Actions failed to completely resolve in 16 iterations"

          # TODO: May be able to consolidate these into the stack resolution
          activeSquad nextActivatableSquad()

          updateVisibleTiles()

          unless self.activeCharacter()
            # End of Round
            self.ready()

        ready: ->
          # Refresh all squads
          squads.forEach (squad) ->
            squad.ready()

          activeSquad nextActivatableSquad()

          if activeSquad()
            self.stateBasedActions()
          else
            ;# No survivors

        message: (message) ->
          self.messages.push message

        performAbility: (owner, ability, targetPosition) ->
          ability.perform owner,
            position: targetPosition
            character: characterAt targetPosition
            addEffect: self.performEffect # TODO: Figure out how to get an effect stack in here

          self.stateBasedActions()

        performEffect: (effect) ->
          effect.perform
            characterAt: characterAt
            tileAt: tileAt
            message: self.message

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
            path.forEach (position) ->
              search.visible(character.position(), character.sight()).map(tileAt).forEach (tile) ->
                tile.seen[index] = true

            self.performAbility(character, self.targettingAbility(), position)

      updateVisibleTiles()

      self.include require("./map_rendering")

      return self
