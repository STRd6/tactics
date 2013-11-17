Squad
=====

    Duder = require "./duder"

A team of 4-6 characters who battle it out with other squads in tactical combat.

    module.exports = Squad = (I={}) ->
      Object.defaults I,
        sprite: "human"
        x: 5

      activatableCharacters = ->
        self.characters.filter (character) ->
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
        stateBasedActions: ->
          self.characters.forEach (character) ->
            character.stateBasedActions()

          if character = self.activeCharacter()
            if character.actions() is 0
              self.activeCharacter nextActivatableCharacter()
        ready: ->
          self.characters.forEach (character) ->
            character.ready()

          debugger

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
