Squad
=====

    Character = require "./character"
    Class = require "./character_classes"

    Compositions = require "./lib/compositions"

    extend = Object.extend

    create = (type, data) ->
      Character extend data, Class[type]

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}, self=Core(I)) ->
      Object.defaults I,
        characters: []
        race: "human"

      self.include Compositions

      self.attrModels "characters", Character

      nextActivatableCharacter = ->
        self.activatableCharacters().first()

      self.extend
        activatableCharacters: ->
          self.characters().filter (character) ->
            character.alive() and
            character.actions() > 0

        activateCharacterAt: (position) ->
          character = self.activatableCharacters().filter (character) ->
            character.position().equal position
          .first()

          if character
            self.activeCharacter(character)

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

      # TODO: Load characters from data
      switch I.race
        when "human"
          self.characters [
            create "Knight",
              position:
                x: 1
                y: 1

            create "Wizard",
              position:
                x: 2
                y: 4

            create "Archer",
              position:
                x: 4
                y: 2

            create "Scout",
              position:
                x: 2
                y: 3
          ]
        when "undead"
          self.characters [
            create "Lich",
              position:
                x: 1
                y: 1

            create "AcidSlime",
              position:
                x: 2
                y: 4

            create "OilSlime",
              position:
                x: 4
                y: 2

            create "FireSlime",
              position:
                x: 2
                y: 3
          ]
        else
          self.characters [
            create "Grunt",
              position:
                x: 18
                y: 16

            create "Wizard",
              position:
                x: 20
                y: 14

            create "ShrubMage",
              position:
                x: 14
                y: 16

            create "Giant",
              position:
                x: 16
                y: 14
          ]

      self.activeCharacter self.characters().first()

      return self
