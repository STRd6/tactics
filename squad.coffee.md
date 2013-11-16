Squad
=====

    Duder = require "./duder"

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}) ->
      nextActivatableCharacter = ->
        self.characters.filter (character) ->
          character.actions() > 0
        .first()

      self =
        activeCharacter: Observable null
        characters: Observable []
        stateBasedActions: ->
          if character = self.activeCharacter()
            if character.actions() is 0
              self.activeCharacter nextActivatableCharacter()

      # TODO: Load characters from data
      self.characters [
        Duder
          position:
            x: 3
            y: 7
          sprite: "human"
        Duder
          position:
            x: 3
            y: 10
          sprite: "human"
        Duder
          position:
            x: 1
            y: 13
          sprite: "human"
        Duder
          position:
            x: 5
            y: 15
          sprite: "human"
      ]

      self.activeCharacter self.characters.first()

      return self
