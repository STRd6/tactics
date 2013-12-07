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
          character.damage(1)

    Effect.Move = (from, to, movingCharacter=null, translocation=false) ->
      perform: ({characterAt, message, impassable}) ->
        # If a character is moving themselves we don't want to move anyone
        if movingCharacter
          character = movingCharacter if movingCharacter.position().equal(from)
        else # An effect that will move any character like knockback
          character = characterAt(from)

        if character
          if impassable(to)
            message "#{character.name()} bumped into an unseen obstruction!"
          else
            # TODO: Enter and exit effects
            character.position(to)
        else
          console.log "No character at", from

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
