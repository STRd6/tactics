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
          character.stun(1)
          character.damage(1)
          message "#{character.name()} is on fire!"

    Effect.Move = (from, to, movingCharacter=null) ->
      perform: ({characterAt, message, impassable, event}) ->
        # If a character is moving themselves we don't want to move anyone else
        # We also don't want to keep moving them if they lose awareness (death, stun).
        if movingCharacter
          if movingCharacter.aware() and movingCharacter.position().equal(from)
            character = movingCharacter
        else # An effect that will move any character, like knockback
          character = characterAt(from)

        if character
          if impassable(to)
            message "#{character.name()} bumped into an unseen obstruction!"
          else
            character.position(to)
            # Enter and exit effects (traps, reaction abilities)
            event "move",
              from: from
              to: to
        else
          console.log "No character at", from

    Effect.Stomp = (position, owner) ->
      perform: ({characterAt, message, search, featuresAt, replaceTileAt}) ->
        # TODO: Add cracked / destroyed sprite
        # TODO: Screen shake
        search.adjacent(position).forEach (position) ->
          if character = characterAt(position)
            unless character is owner
              message "#{character.name()} has been shaken by #{owner.name()}'s mighty stomp."
              character.damage(1)
              character.stun(2)

          featuresAt(position).invoke "destroy"

          # Revert tiles to default
          replaceTileAt(position)

    # Used in Entanglement
    Effect.Plant = (position) ->
      perform: ({characterAt, message, addFeature, impassable}) ->
        unless impassable(position)
          # TODO: Check for existing bushes
          addFeature Feature.Bush(position)

        if character = characterAt(position)
          character.stun(1)
          message "#{character.name()} is caught in a shrub!"

    Effect.Death = (position, owner) ->
      perform: ({message, addFeature}) ->
        message "#{owner.name()} has been slain."

        addFeature Feature
          spriteName: "skeleton"
          position: position

    Effect.ShrubSight = (position, owner) ->
      # TODO: Redo this 'find' idea to make use of the quadtree
      # build in radii, etc
      perform: ({find}) ->
        find("plant").within(position, 13).forEach (plant) ->
          owner.addMagicalVision(plant.position())

    Effect.StoneSight = (position, owner) ->
      # TODO: Redo this 'find' idea to make use of the quadtree
      # build in radii, etc
      perform: ({find}) ->
        find("stone").within(position, 13).forEach (stone) ->
          owner.addMagicalVision(plant.position())
