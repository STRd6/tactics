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
      perform: ({tileAt, characterAt, message}) ->
        if tile = tileAt(position)
          # Fireball Effect
          Object.extend tile,
            opaque: false
            solid: false
            features: []
            sprite: lavaSprites.rand()

          tile.features.push Feature.Fire()

          if character = characterAt(position)
            message "#{character.name()} is on fire!"
            character.damage(2)

    # Used in Entanglement
    Effect.Plant = (position) ->
      perform: ({characterAt, tileAt, message}) ->
        if tile = tileAt(position)
          unless tile.solid
            # TODO: Check for existing bushes
            # TODO: Add movement penalty to bush features
            # TODO: Transfer opacity computation from to include features
            tile.opaque = true
            tile.features.push Feature.Bush()

          if character = characterAt(position)
            message "#{character.name()} is caught in a shrub!"

    Effect.Death = (position, owner) ->
      perform: ({tileAt, message}) ->
        message "#{owner.name()} has been slain."

        if tile = tileAt(position)
          tile.features.push Feature
            spriteName: "skeleton"
