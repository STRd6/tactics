Squad
=====

    Character = require "./character"
    Class = require "./character_classes"

    Compositions = require "./lib/compositions"

    extend = Object.extend

    create = (type, position) ->
      Character extend
        position: position
      , Class[type]

    defaultCharacters =
      goblin: [
        "Grunt"
        "Wizard"
        "ShrubMage"
        "Giant"
      ]
      human: [
        "Knight"
        "Archer"
        "Scout"
        "Wizard"
      ]
      spunk: [
        "OilSlime"
        "OilSlime"
        "AcidSlime"
        "AcidSlime"
        "FireSlime"
        "FireSlime"
      ]
      undead: [
        "Lich"
        "Harpy"
        "Skeleton"
        "Skeleton"
      ]

    defaultPositions = [[
      Point(1, 1)
      Point(2, 4)
      Point(2, 3)
      Point(4, 2)
      Point(4, 4)
      Point(6, 4)
    ],[
      Point(18, 16)
      Point(14, 16)
      Point(16, 14)
      Point(20, 14)
    ]]

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}, self=Core(I)) ->
      Object.defaults I,
        characters: []
        index: 0
        race: "human"

      self.include Compositions

      self.attrAccessor(
        "race"
      )

      self.attrModels "characters", Character

      nextActivatableCharacter = ->
        self.activatableCharacters().first()

      self.extend
        activatableCharacters: ->
          self.characters().filter (character) ->
            character.alive() and
            character.actions() > 0

        activateCharacterAt: (position) ->
          if character = self.characterAt(position)
            self.activeCharacter(character)

        characterAt: (position) ->
          self.activatableCharacters().filter (character) ->
            character.position().equal position
          .first()

        activeCharacter: Observable null

        stateBasedActions: (params) ->
          self.characters().forEach (character) ->
            character.stateBasedActions(params)

          # TODO: This isn't really a state based action, more of a UI helper
          # for the player
          if character = self.activeCharacter()
            if character.actions() is 0
              self.activeCharacter nextActivatableCharacter()

        ready: ->
          self.characters().forEach (character) ->
            character.ready()

          self.activeCharacter nextActivatableCharacter()

        toJSON: ->
          Object.extend I,
            characters: self.characters().invoke "toJSON"

      if self.characters().length is 0
        # Load from presets
        self.characters defaultCharacters[I.race].map (type, i) ->
          create type, defaultPositions[I.index][i]

      self.activeCharacter nextActivatableCharacter()

      return self
