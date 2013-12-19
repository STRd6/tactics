Character
=========

Those little guys that run around.

    Ability = require "./ability"
    Action = require "./action"
    Drawable = require "./lib/drawable"
    Effect = require "./effect"
    Names = require "./names"
    Passive = require "./passive"

    {sqrt, min, max} = Math

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)

      Object.defaults I,
        abilities: [
          "Move"
          "Melee"
        ]
        passives: []
        actions: 2
        alive: true
        cooldowns: {}
        effects: []
        health: 3
        healthMax: 3
        magicalVision: []
        movement: 4
        name: Names.male.rand()
        physicalAwareness: sqrt(2)
        sight: 7
        strength: 1
        stun: 0

      self.attrAccessor(
        "abilities"
        "actions"
        "alive"
        "debugPositions"
        "health"
        "healthMax"
        "magicalVision"
        "movement"
        "name"
        "physicalAwareness"
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

      self.include Drawable

      Object.extend self,
        damage: (amount, type) ->
          damageTotal = self.damageMod(amount, type)

          I.health -= damageTotal

        heal: (amount) ->
          I.health += amount

        cooldown: (ability) ->
          I.cooldowns[ability.name()] or 0

        setCooldown: (ability) ->
          I.cooldowns[ability.name()] = ability.cooldown()

        addMagicalVision: (position) ->
          I.magicalVision.push position

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

        damageMod: (amount, type="Physical") ->
          if self.immune(type)
            return 0

          # TODO: Resistances

          return amount

        immune: (type) ->
          self.immunities().include(type)

        immunities: (type) ->
          self.passives().map (passive) ->
            passive.immune
          .compact()

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
            addEffect Effect.Death(self.position(), self)

          Object.keys(I.cooldowns).forEach (name) ->
            if I.cooldowns[name] < 0
              I.cooldowns[name] = 0

          if I.stun < 0
            I.stun = 0

          return

        stun: (stun) ->
          console.log "#1 Stunna", stun
          I.stun = Math.max(I.stun, stun)
          I.actions = 0

        stunned: ->
          I.stun > 0

        aware: () ->
          self.alive() and !self.stunned()

Effects to occur when this character enters a tile.

        enterEffects: ->
          self.passives().map (passive) ->
            passive.enter
          .compact()

        physicalAwareness: ->
          if !self.aware()
            0
          else
            I.physicalAwareness + self.mods(name)

        targettingAbility: Observable()
        resetTargetting: ->
          self.targettingAbility null

Ready is called at the beginning of each turn. It resets the actions and processes
any status effects.

        ready: ->
          # Remove all magical vision
          # TODO: Maybe have separate vision effects with their own durations
          I.magicalVision = []

          I.stun -= 1 if I.stun > 0

          Object.keys(I.cooldowns).forEach (name) ->
            I.cooldowns[name] -= 1

          I.effects.forEach (effect) ->
            effect.duration -= 1

          if I.stun is 0
            I.actions = 2
          else
            I.actions = 0

        passives: ->
          I.passives.map (name) ->
            Passive.Passives[name]

        visionType: ->
          self.passives().reduce (memo, passive) ->
            memo or passive.visionType
          , undefined

      return self
