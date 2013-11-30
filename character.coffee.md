Character
=========

Those little guys that run around.

    Ability = require "./ability"
    Action = require "./action"
    Effect = require "./effect"
    Resource = require "./resource"
    Names = require "./names"

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)

      Object.defaults I,
        abilities: [
          "Melee"
        ]
        actions: 2
        alive: true
        cooldowns: {}
        effects: []
        health: 3
        healthMax: 3
        movement: 4
        name: Names.male.rand()
        sight: 7
        strength: 1

      self.attrAccessor(
        "alive"
        "actions"
        "health"
        "healthMax"
        "movement"
        "name"
        "position"
        "sight"
        "strength"
      )

      effectModifiable = (names...) ->
        names.forEach (name) ->
          method = self[name]

          self[name] = (args...) ->
            if args.length > 0
              method(args...)
            else
              method() + self.mods(name)

      effectModifiable(
        "sight"
        "strength"
      )

      Object.extend self,
        sprite: ->
          Resource.sprite(I.spriteName) or Sprite.NONE
  
        damage: (amount) ->
          I.health -= amount

        heal: (amount) ->
          I.health += amount

        cooldown: (ability) ->
          I.cooldowns[ability.name()] or 0

        setCooldown: (ability) ->
          I.cooldowns[ability.name()] = ability.cooldown()

        addEffect: (effect) ->
          I.effects.push effect

Sums up the modifications for an attribute from all the effects.

        mods: (attribute) ->
          I.effects.reduce (total, effect) ->
            if effect.attribute is attribute
              total + effect.amount
            else
              total
          , 0

        stateBasedActions: ({addEffect}) ->
          return if !I.alive

          # Clear expired effects
          I.effects = I.effects.filter (effect) ->
            effect.duration > 0

          # Cap health
          if I.health > I.healthMax
            I.health = I.healthMax

          # Clamping actions and cooldowns
          if I.health <= 0
            # Died
            I.alive = false
            I.actions = 0

            # Push death effect
            addEffect Effect.Death(self.position())

          Object.keys(I.cooldowns).forEach (name) ->
            if I.cooldowns[name] < 0
              I.cooldowns[name] = 0

          # Reset action statuses
          actions.forEach (action) ->
            action.disabled !action.ability.canPay(self)

        targettingAbility: Observable()

        updatePosition: (newPosition) ->
          self.position newPosition

Ready is called at the beginning of each turn. It resets the actions and processes
any status effects.

        ready: ->
          Object.keys(I.cooldowns).forEach (name) ->
            I.cooldowns[name] -= 1

          I.effects.forEach (effect) ->
            effect.duration -= 1

          I.actions = 2

      abilities = I.abilities.concat("Move", "Wait", "Cancel").map (name) ->
        Ability.Abilities[name]

      actions = abilities.map (ability) ->
        action = Action
          name: ability.name()
          icon: ability.iconName()
          perform: ->
            self.targettingAbility(ability)

        # TODO: Mayb be a cleaner way to do this
        # but it's needed for updating enabled/disabled status
        action.ability = ability

        action.active = Observable ->
          ability is self.targettingAbility()

        return action

      self.uiActions = ->
        actions

      self.resetTargetting = ->
        self.targettingAbility null

      return self
