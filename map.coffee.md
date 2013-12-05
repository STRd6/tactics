Map
===

The primary tactical combat screen.

    Ability = require "./ability"
    Compositions = require "./lib/compositions"
    Feature = require "./feature"
    Graph = require "./graph"
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
        height: 18
        width: 32

      self ?= Core(I)

      self.attrAccessor "width", "height"

      self.extend
        tileCount: ->
          I.width * I.height

      self.include Compositions
      
      self.include MapTiles

      self.attrModels "squads", Squad

      self.attrModels "features", Feature
      # TODO: Temporary hack to add bushes and walls
      self.tileCount().times (i) ->
        position = Point(i % 32, Math.floor(i / 32))
        if rand() < 0.1
          self.features.push Feature.Wall(position)
        else if rand() < 0.25
          self.features.push Feature.Bush(position)

      self.attrObservable "currentTurn"

      activeSquad = Observable ->
        self.squads().wrap(self.currentTurn())

      featuresAt = (position) ->
        self.features().filter (feature) ->
          feature.position().equal(position)

      # TODO: Think about chunking features in a quad tree or something

      # TODO: Inculde character as an optional parameter
      impassable = (position) ->
        featuresAt(position).some (feature) ->
          feature.impassable()

      # TODO: Include character as an optional parameter
      opaque = (position) ->
        featuresAt(position).some (feature) ->
          feature.opaque()

      characterPassable = (character) ->
        (position) ->
          if occupant = characterAt(position)
            occupantPassable = (activeSquad().characters.indexOf(occupant) != -1)
          else
            occupantPassable = true

          !impassable(position) and self.lit.get(self.activeSquadIndex()).get(position.x + position.y * self.width()) and occupantPassable

      characterAt = (x, y) ->
        if x.x?
          {x, y} = x

        self.characters().filter (character) ->
          position = character.position()
          character.alive() and (position.x is x and position.y is y)
        .first()

      search = MapSearch()

      effectStack = []
      featuresToAdd = []

      self.include require("./map_serialization")

      self.include require "finder"
      oldFind = self.find
      self.find = (selector) ->
        results = oldFind(self.features(), selector)
        
        # TODO: Hacks!
        results.within = (position, radius) ->
          newResults = results.filter (result) ->
            radius <= Point.distance(result.position(), position())
          
          newResults.within = results.within
          results = newResults

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

          while featuresToAdd.length
            feature = featuresToAdd.pop()

            self.features.push feature

          # TODO: May not want to do this ALL the time
          self.updateVisibleTiles()

          unless self.activeCharacter()
            # End of turn
            self.ready()

        ready: ->
          self.currentTurn(self.currentTurn() + 1)
          self.updateFeatures()

          # Refresh newly active squad
          activeSquad().ready()

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

        addFeature: (feature) ->
          feature.createdAt(I.currentTurn)
          featuresToAdd.push(feature)

        updateFeatures: ->
          # Updating and filtering features to only the active features
          self.features self.features().filter (feature) ->
            feature.update
              addEffect: self.addEffect
              addFeature: self.addFeature
              characterAt: characterAt
              find: self.find
              message: self.message
              turn: I.currentTurn / I.squads.length

        performAbility: (owner, ability, targetPosition) ->
          ability.perform
            addEffect: self.addEffect
            addFeature: self.addFeature
            character: characterAt targetPosition
            characterAt: characterAt
            impassable: impassable
            message: self.message
            owner: owner
            position: targetPosition

          self.stateBasedActions()

        performEffect: (effect) ->
          effect.perform
            addEffect: self.addEffect
            addFeature: self.addFeature
            characterAt: characterAt
            impassable: impassable
            message: self.message

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
              self.viewTiles search.visible(character.position(), character.sight(), opaque), index

            self.performAbility(character, self.targettingAbility(), position)

      self.updateVisibleTiles()

      self.include require("./map_rendering")

      return self
