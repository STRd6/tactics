Squad
=====

    Character = require "./character"
    Class = require "./character_classes"

    extend = Object.extend

    create = (type, data) ->
      Character extend data, Class[type]

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}) ->
      Object.defaults I,
        race: "human"
        x: 5

      activatableCharacters = ->
        self.characters.filter (character) ->
          character.alive() and
          character.actions() > 0

      nextActivatableCharacter = ->
        activatableCharacters().first()

      self =
        activateCharacterAt: (position) ->
          character = activatableCharacters().filter (character) ->
            character.position().equal position
          .first()

          if character
            self.activeCharacter(character)

        activeCharacter: Observable null
        characters: Observable []

        stateBasedActions: (params) ->
          self.characters.forEach (character) ->
            character.stateBasedActions(params)

          if character = self.activeCharacter()
            if character.actions() is 0
              self.activeCharacter nextActivatableCharacter()

        ready: ->
          self.characters.forEach (character) ->
            character.ready()

          self.activeCharacter nextActivatableCharacter()

      # TODO: Load characters from data
      if I.race is "human"
        self.characters [
          create "Knight",
            position:
              x: I.x - 1
              y: 7

          create "Wizard",
            position:
              x: I.x - 2
              y: 10

          create "Archer",
            position:
              x: I.x - 4
              y: 13

          create "Archer",
            position:
              x: rand(8) + 2
              y: 3
        ]
      else
        self.characters [
          create "Grunt",
            position:
              x: I.x - 1
              y: 7
          create "Grunt",
            position:
              x: I.x - 2
              y: 5
          create "ShrubMage",
            position:
              x: I.x - 2
              y: 10
          create "Grunt",
            position:
              x: I.x - 4
              y: 13
        ]

      self.activeCharacter self.characters.first()

      return self
