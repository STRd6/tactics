Duder
=====

Those little guys that run around.

Use Shadowcasting for FoV calculations.

    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"
    Action = require "./action"
    Ability = require "./ability"

    {TARGET_TYPE, TARGET_ZONE, COST_TYPE} = Ability
    {sqrt} = Math

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
      # TODO: Disentangle this tileAt dependency
      fov.tileAt = (args...) ->
        self.tileAt(args...)

      Object.extend self,
        visibleTiles: ->
          fov.calculate(self.position(), self.sight())

        targettingAbility: Observable()

        updatePosition: (newPosition) ->
          self.position newPosition

Ready is called at the beginning of each turn. It resets the actions and processes
any status effects.

        ready: ->
          I.actions = 2

      abilities = [
        Ability
          name: "Move"
          iconName: "boots"
          actionCost: 1
          targetZone: TARGET_ZONE.MOVEMENT
          perform: (owner, {path}) ->
            path.forEach (position) ->
              self.updatePosition position
              self.visibleTiles().forEach (tile) ->
                tile.seen = true

        Ability
          name: "Attack"
          iconName: "sword"
          range: sqrt(2)
          actionCost: 1
          costType: COST_TYPE.REST
          targetZone: TARGET_ZONE.LINE_OF_SIGHT
          perform: (owner, {position, character}) ->
            if character
              character.I.health -=1

        Ability
          name: "Wait"
          iconName: "hourglass"
          actionCost: 1
          costType: COST_TYPE.REST
          targetZone: TARGET_ZONE.SELF
          perform: ->
      ]

      actions = abilities.map (ability) ->
        action = Action
          name: ability.name()
          icon: ability.iconName()
          perform: ->
            self.targettingAbility(ability)

        action.active = Observable ->
          ability is self.targettingAbility()

        return action

      self.uiActions = ->
        actions

      self.resetTargetting = ->
        self.targettingAbility null

      return self
