Effect
======

    Feature = require "./feature"
    Resource = require "./resource"

    lavaSprites = [0..11].map (n) ->
      Resource.sprite("lava#{n}")

Effects are things like explosions or dispelling undead. Maybe even fire or
electricity, I don't know yet.

    module.exports = Effect = (I={}, self=Core(I)) ->
      # TODO

    # Used in Fireball
    Effect.Fire = (position) ->
      perform: ({tileAt, characterAt, message, addFeature}) ->
        if tile = tileAt(position)
          # Fireball Effect
          Object.extend tile,
            features: []
            sprite: lavaSprites.rand()

          addFeature(Feature.Fire(), position)

          if character = characterAt(position)
            message "#{character.name()} is on fire!"
            character.damage(2)

    # Used in Entanglement
    Effect.Plant = (position) ->
      perform: ({characterAt, tileAt, message}) ->
        if tile = tileAt(position)
          unless tile.impassable()
            # TODO: Check for existing bushes
            # TODO: Add movement penalty to bush features
            tile.addFeature Feature.Bush()

          if character = characterAt(position)
            message "#{character.name()} is caught in a shrub!"

    Effect.Death = (position, owner) ->
      perform: ({tileAt, message}) ->
        message "#{owner.name()} has been slain."

        if tile = tileAt(position)
          tile.addFeature Feature
            spriteName: "skeleton"

    Effect.ShrubSight = (position, owner) ->
      perform: ({tileAt}) ->
        if tile = tileAt(position)
          # TODO: Maybe have a featureAt method passed in rather than use tile.features
          hasPlant = tile.hasType "plant"

          # Add magical vision to owner if tile has a `plant` feature
          if hasPlant
            owner.addMagicalVision(position)
