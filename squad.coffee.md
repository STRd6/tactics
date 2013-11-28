Squad
=====

    Character = require "./character"

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
          Character
            position:
              x: I.x - 1
              y: 7
            health: 4
            healthMax: 4
            sprite: "human"
          Character
            position:
              x: I.x - 2
              y: 10
            health: 2
            healthMax: 2
            sprite: "wizard"
            abilities: [
              "Blink"
              "Entanglement"
            ]
          Character
            position:
              x: I.x - 4
              y: 13
            sprite: "elf_archer"
            abilities: [
              "Ranged"
            ]
        ]
      else
        self.characters [
          Character
            position:
              x: I.x - 1
              y: 7
            sprite: "goblin"
            abilities: [
              "Melee"
              "Regeneration"
            ]
          Character
            position:
              x: I.x - 2
              y: 10
            sprite: "goblin"
            abilities: [
              "Melee"
              "Regeneration"
            ]
          Character
            position:
              x: I.x - 4
              y: 13
            sprite: "goblin"
            abilities: [
              "Melee"
              "Regeneration"
            ]
        ]

      self.activeCharacter self.characters.first()

      return self
