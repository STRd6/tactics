Squad
=====

    Duder = require "./duder"

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}) ->
      Object.defaults I,
        sprite: "human"
        x: 5
    
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
        ready: ->
          self.characters.forEach (character) ->
            character.ready()

          self.activeCharacter nextActivatableCharacter()

      # TODO: Load characters from data
      self.characters [
        Duder
          position:
            x: I.x - 1
            y: 7
          sprite: I.sprite
        Duder
          position:
            x: I.x - 2
            y: 10
          sprite: I.sprite
        Duder
          position:
            x: I.x - 4
            y: 13
          sprite: I.sprite
      ]

      self.activeCharacter self.characters.first()

      return self
