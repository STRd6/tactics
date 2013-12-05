Effect
======

    Feature = require "./feature"
    Resource = require "./resource"

    lavaSprites = [0..11].map (n) ->
      Resource.sprite("lava#{n}")

Effects are things like explosions or dispelling undead. Maybe even fire or
electricity, I don't know yet.

    module.exports = Effect = (I={}, self=Core(I)) ->

    # Used in Fireball
    Effect.Fire = (position) ->
      perform: ({characterAt, message, addFeature}) ->
        addFeature(Feature.Fire(position))

        if character = characterAt(position)
          message "#{character.name()} is on fire!"
          character.damage(2)

    # Used in Entanglement
    Effect.Plant = (position) ->
      perform: ({characterAt, message, addFeature, impassable}) ->
        unless impassable(position)
          # TODO: Check for existing bushes
          addFeature Feature.Bush(position)

        if character = characterAt(position)
          message "#{character.name()} is caught in a shrub!"

    Effect.Death = (position, owner) ->
      perform: ({message, addFeature}) ->
        message "#{owner.name()} has been slain."

        addFeature Feature
          spriteName: "skeleton"
          position: position

    Effect.ShrubSight = (position, owner) ->
      perform: ({find}) ->
        find("plant").within(position, 13).forEach (plant) ->
          owner.addMagicalVision(plant.position())
