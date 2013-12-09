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

      activatableCharacters = ->
        self.characters().filter (character) ->
          character.alive() and
          character.actions() > 0

      nextActivatableCharacter = ->
        activatableCharacters().first()

      self.extend
        activateCharacterAt: (position) ->
          character = activatableCharacters().filter (character) ->
            character.position().equal position
          .first()

          if character
            self.activeCharacter(character)

        activeCharacter: Observable null

        stateBasedActions: (params) ->
          self.characters().forEach (character) ->
            character.stateBasedActions(params)

          if character = self.activeCharacter()
            if character.actions() is 0
              self.activeCharacter nextActivatableCharacter()

        ready: ->
          self.characters().forEach (character) ->
            character.ready()

          self.activeCharacter nextActivatableCharacter()

      # TODO: Load characters from data
      if I.race is "human"
        self.characters [
          create "Knight",
            position:
              x: 1
              y: 7

          create "Wizard",
            position:
              x: 2
              y: 10

          create "Archer",
            position:
              x: 4
              y: 13

          create "Scout",
            position:
              x: 2
              y: 3
        ]
      else
        self.characters [
          create "Grunt",
            position:
              x: 10
              y: 7

          create "ShrubMage",
            position:
              x: 8
              y: 10

          create "Grunt",
            position:
              x: 12
              y: 13

          create "Giant",
            position:
              x: 4
              y: 7
        ]

      self.activeCharacter self.characters().first()

      return self
