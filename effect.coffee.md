Effect
======

    Feature = require "./feature"
    Resource = require "./resource"

    lavaSprites = [0..11].map (n) ->
      Resource.sprite("lava#{n}")

Effects are things like explosions or dispelling undead. Maybe even fire or
electricity, I don't know yet.

    module.exports = Effect = (I={}, self=Core(I)) ->

      perform: ({position, tileAt, characterAt, message}) ->
        if tile = tileAt(position)
          # Fireball Effect
          Object.extend tile,
            opaque: false
            solid: false
            features: []
            sprite: lavaSprites.rand()

          if character = characterAt(position)
            message("#{character.name()} is burned!")
            character.damage(2)

    Effect.Death =
      perform: ({position, tileAt}) ->
        if tile = tileAt(position)
          tile.features.push Feature
            spriteName: "skeleton"
