Map
===

The primary tactical combat screen.

    Ability = require "./ability"
    Compositions = require "./lib/compositions"
    Effect = require "./effect"
    MapFeatures = require "./map_features"
    MapSearch = require "./map_search"
    MapTiles = require "./map_tiles"
    Squad = require "./squad"

    {
      intersection
    } = require "./array_helpers"

    module.exports = (I={}, self) ->
      Object.defaults I,
        currentTurn: 0
        features: []
        squads: [{
          # TODO
        }, {
          race: "goblin"
        }]
        height: 36
        width: 64

      self ?= Core(I)

      self.include Compositions

      self.attrAccessor "width", "height"

      self.attrObservable "currentTurn"

      self.tileCount = ->
        I.width * I.height

      self.include MapTiles
      self.include MapFeatures

      self.attrModels "squads", Squad
      self.activeSquad = Observable ->
        self.squads().wrap(self.currentTurn())

      # TODO: Inculde character as an optional parameter
      impassable = (position) ->
        self.featuresAt(position).some (feature) ->
          feature.impassable()

      # TODO: Include character as an optional parameter
      opaque = (position) ->
        self.featuresAt(position).some (feature) ->
          feature.opaque()

      characterPassable = (character) ->
        index = self.activeSquadIndex()

        (position) ->
          if self.featuresAt(position).some((feature) -> feature.seen(index) and feature.dangerous())
            occupantPassable = false
          else if occupant = characterAt(position)
            occupantPassable = (self.activeSquad().characters.indexOf(occupant) != -1)
          else
            occupantPassable = true

          !impassable(position) and self.lit.get(index).get(position.x + position.y * self.width()) and occupantPassable

      characterAt = (x, y) ->
        if x.x?
          {x, y} = x

        self.characters().filter (character) ->
          position = character.position()
          character.alive() and (position.x is x and position.y is y)
        .first()

      search = MapSearch()

      effectStack = []

      self.include require("./map_serialization")

      self.include require "finder"
      oldFind = self.find
      typeMatcher = (type, object) ->
        object.type() is type
      self.find = (selector) ->
        results = oldFind(self.features(), selector, typeMatcher)

        results.within = (position, radius) ->
          results.filter (result) ->
            Point.distance(result.position(), position) <= radius

        return results

      self.extend
        messages: Observable []

        activeSquadIndex: ->
          # NOTE: Assumes squad length never changes
          self.currentTurn() % I.squads.length

        characters: Observable ->
          self.squads().map (squad) ->
            squad.characters()
          .flatten()

        characterAt: characterAt

        eachTile: self.tiles().each

        opaque: opaque

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
                # TODO this auto-perform doesn't belong here, it should be done
                # in the caller if one so wishes
                self.performAbility(character, ability, character.position())

                return
              when Ability.TARGET_ZONE.MOVEMENT
                accessiblePositions = search.accessible(character.position(), character.movement(), characterPassable(character))

                accessiblePositions.reject (position) ->
                  characterAt(position)

              when Ability.TARGET_ZONE.ANY
                positionsInRange = search.adjacent(character.position(), ability.range())

              when Ability.TARGET_ZONE.LINE_OF_SIGHT
                visiblePositions = search.visible(character.position(), character.sight(), opaque)
                positionsInRange = search.adjacent(character.position(), ability.range())

                intersection(
                  visiblePositions
                  positionsInRange
                )

        stateBasedActions: ->
          self.squads().forEach (squad) ->
            squad.stateBasedActions
              addEffect: self.addEffect

          while effectStack.length
            # TODO: This could fall victim to infinite recursion
            self.performEffect effectStack.pop()

          self.addNewFeatures()

          self.updateVisibleTiles
            message: self.message

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
          if Ability.TARGET_ZONE.MOVEMENT
            movementPath = search.movementPath(
              owner.position(),
              targetPosition,
              characterPassable(owner)
            )

          ability.perform
            addEffect: self.addEffect
            addFeature: self.addFeature
            character: characterAt targetPosition
            characterAt: characterAt
            find: self.find
            impassable: impassable
            message: self.message
            movementPath: movementPath
            owner: owner
            position: targetPosition

          self.stateBasedActions()

        performEffect: (effect) ->
          effect.perform
            addEffect: self.addEffect
            addFeature: self.addFeature
            characterAt: characterAt
            impassable: impassable
            find: self.find
            message: self.message
            event: self.trigger
            search: search
            featuresAt: self.featuresAt

          self.stateBasedActions()

        selectTarget: (targetPosition) ->
          ability = self.targettingAbility()
          character = self.activeCharacter()

          self.performAbility(character, ability, targetPosition)

        trigger: (name, params) ->
          # TODO: Think more about event listeners

          if name is "move"
            self.featuresAt(params.to).forEach (feature) ->
              feature.enter
                addEffect: self.addEffect
                addFeature: self.addFeature
                characterAt: characterAt
                effect: (name, params) ->
                  self.addEffect Effect[name](params)
                impassable: impassable
                find: self.find
                message: self.message
                event: self.trigger

      # TODO: This should be done by an initial runthrough of state based actions
      # instead
      self.updateVisibleTiles
        message: self.message

      self.include require("./map_rendering")

      return self
