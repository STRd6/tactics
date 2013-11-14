Duder
=====

Those little guys that run around.

Use Shadowcasting for FoV calculations.

    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"
    Action = require "./action"
    Ability = require "./ability"

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)
      I.sprite = Resource.sprite(I.sprite)

      Object.defaults I,
        sight: 7
        movement: 4
        health: 3
        healthMax: 3
        actions: 2

      self.attrAccessor(
        "actions"
        "health"
        "healthMax"
        "movement"
        "position"
        "sprite"
        "sight"
      )

      fov = new Shadowcasting()
      fov.tileAt = (args...) ->
        self.tileAt(args...)

      self.visibleTiles = ->
        fov.calculate(self.position(), self.sight())

      self.move = (newPosition) ->
        I.actions -= 1
        self.position newPosition

      self.targettingAbility = Observable()

      self.updatePosition = (newPosition) ->
        self.position newPosition

Ready is called at the beginning of each turn. It resets the actions and processes
any status effects.

      self.ready = ->
        I.actions = 2

      abilities = [
        Ability
          name: "Move"
          iconName: "boots"
          range: (character) ->
            character.movement()
          actionCost: 1
          targetType: Ability.TARGET_TYPE.MOVEMENT
          perform: () ->

        Ability
          name: "Wait"
          iconName: "hourglass"
          actionCost: 1
          costType: Ability.COST_TYPE.REST
          targetType: Ability.TARGET_TYPE.SELF
          perform: (self) ->

      ]

      self.uiActions = ->
        abilities.map (ability) ->
          Action
            name: ability.name()
            icon: ability.iconName()
            perform: ->
              switch ability.targetType
                when TARGET_TYPE.SELF
                  ability.perform(self)
                when TARGET_TYPE.MOVEMENT
                  ; # TODO

      return self
