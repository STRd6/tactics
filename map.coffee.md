Map
===

The primary tactical combat screen.

    Ability = require "./ability"
    Compositions = require "./lib/compositions"
    Effect = require "./effect"
    MapFeatures = require "./map_features"
    MapHotkeys = require "./map_hotkeys"
    MapSearch = require "./map_search"
    MapTiles = require "./map_tiles"
    MapRendering = require "./map_rendering"
    Squad = require "./squad"

    {
      intersection
    } = require "./array_helpers"

    module.exports = (I={}, self) ->
      Object.defaults I,
        currentTurn: 0
        messages: []
        squads: [{
          race: "spunk"
          index: 0
        }, {
          race: "goblin"
          index: 1
        }]

      self ?= Core(I)

      self.include Compositions

      self.attrObservable "currentTurn"

      self.include MapFeatures
      self.include MapTiles
      self.include MapHotkeys

      self.attrModels "squads", Squad
      self.activeSquad = Observable ->
        self.squads().wrap(self.currentTurn())

      self.attrObservable "messages"

      characterPassable = (character) ->
        index = self.activeSquadIndex()

        (position) ->
          if self.featuresAt(position).some((feature) -> feature.seen(index) and feature.dangerous())
            occupantPassable = false
          else if occupant = self.characterAt(position)
            occupantPassable = (self.activeSquad().characters.indexOf(occupant) != -1)
          else
            occupantPassable = true

          !self.impassable(position) and self.lit.get(index).get(position.x + position.y * self.width()) and occupantPassable

      search = MapSearch()

      effectStack = []

      self.include require("./map_serialization")

      self.include require "./map_find"

      self.extend
        activeSquadIndex: ->
          # NOTE: Assumes squad length never changes
          self.currentTurn() % I.squads.length

        characters: Observable ->
          self.squads().map (squad) ->
            squad.characters()
          .flatten()

        characterAt: (x, y) ->
          if x.x?
            {x, y} = x

          self.characters().filter (character) ->
            position = character.position()
            character.alive() and (position.x is x and position.y is y)
          .first()

        eachTile: self.tiles().each

        visibleCharacters: ->
          self.characters().filter (character) ->
            self.isLit(character.position())

        activeCharacter: Observable ->
          # Dependencies for observable
          self.squads().forEach (squad) ->
            squad.activeCharacter()

          self.activeSquad()?.activeCharacter()

        targettingAbility: ->
          if character = self.activeCharacter()
            character.targettingAbility()

TODO: Make this easier to control via an AI.

TODO: This should be more accurately called valid targets, we may want to
parameterize it by passing in the character and the ability.

        accessiblePositions: ->
          character = self.activeCharacter()

          if ability = self.targettingAbility()
            switch ability.targetZone()
              when Ability.TARGET_ZONE.SELF
                [character.position()]
              when Ability.TARGET_ZONE.MOVEMENT
                accessiblePositions = search.accessible(character.position(), character.movement(), characterPassable(character))

                accessiblePositions.reject (position) ->
                  self.characterAt(position)

              when Ability.TARGET_ZONE.ANY
                positionsInRange = search.adjacent(character.position(), ability.range())

              when Ability.TARGET_ZONE.LINE_OF_SIGHT
                visiblePositions = search.visible(character.position(), character.sight(), self.opaque)
                magicalVision = character.magicalVision()
                positionsInRange = search.adjacent(character.position(), ability.range())

                intersection(
                  visiblePositions.concat(magicalVision)
                  positionsInRange
                )

        stateBasedActions: ->
          while effectStack.length
            # TODO: This could fall victim to infinite recursion
            self.performEffect effectStack.pop()

          self.addNewFeatures()

          self.squads().forEach (squad) ->
            squad.stateBasedActions
              addEffect: self.addEffect

          self.updateVisibleTiles
            message: self.message

          # TODO: This isn't really state based actions, it should be an explicit
          # end turn created from the UI automaticall or the player manually
          unless self.activeCharacter()
            # End of turn
            self.ready()

        ready: ->
          console.log "Ready"
          self.currentTurn(self.currentTurn() + 1)
          self.updateFeatures()

          # Refresh newly active squad
          self.activeSquad().ready()

          if self.activeCharacter()
            self.stateBasedActions()
          else
            # TODO: This squad is wiped out, pop up win condition though we may
            # want to check as SBAs rather than just on ready event

        search: search

        message: (message) ->
          self.messages.push message + "\n"

        addEffect: (effect) ->
          effectStack.push effect

        performAbility: (owner, ability, targetPosition) ->
          if ability.targetZone() is Ability.TARGET_ZONE.MOVEMENT
            movementPath = search.movementPath(
              owner.position(),
              targetPosition,
              characterPassable(owner)
            )

          ability.perform self.methodObject
            character: self.characterAt targetPosition
            movementPath: movementPath
            owner: owner
            position: targetPosition

          self.stateBasedActions()

        effect: (name, params...) ->
          self.addEffect Effect[name](params...)

        # TODO: Kind of a hack, don't call StateBasedActions
        effectInstant: (name, params...) ->
          effect = Effect[name](params...)
          effect.perform self.methodObject()

        performEffect: (effect) ->
          effect.perform self.methodObject()

          self.stateBasedActions()

        methodObject: (extraParams={}) ->
          Object.extend
            addFeature: self.addFeature
            animate: self.animate
            characterAt: self.characterAt
            effect: self.effect
            event: self.trigger
            feature: self.feature
            featuresAt: self.featuresAt
            find: self.find
            findTiles: self.findTiles
            impassable: self.impassable
            message: self.message
            replaceTileAt: self.replaceTileAt
            search: search
            turn: I.currentTurn
          , extraParams

        selectTarget: (targetPosition) ->
          ability = self.targettingAbility()
          character = self.activeCharacter()

          self.performAbility(character, ability, targetPosition)

        trigger: (name, params) ->
          # TODO: Think more about event listeners

          if name is "move"
            self.featuresAt(params.to).forEach (feature) ->
              feature.enter self.methodObject()

            if character = params.character
              character.enterEffects().forEach (effectName) ->
                # TODO: Consolidate these to be I params
                self.effect effectName, params.to, params.character

      self.include MapRendering
      self.animate
        position: self.activeCharacter().position()
        duration: 0

      self.stateBasedActions()

      return self
