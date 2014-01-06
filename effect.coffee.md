Effect
======

    # TODO: Shouldn't have to depend on Feature
    Feature = require "./feature"

Effects are things like explosions or dispelling undead. Maybe even fire or
electricity, I don't know yet.

    module.exports = Effect = (I={}, self=Core(I)) ->

    Effect.Clairvoyance = (position, owner) ->
      radius = 7

      perform: ({search}) ->
        search.adjacent(position, radius).forEach (position) ->
          owner.addMagicalVision(position)

    # Used in Fireball
    Effect.Fire = (position) ->
      perform: ({characterAt, message, addFeature, impassable, replaceTileAt}) ->
        replaceTileAt(position)
        addFeature(Feature.Fire(position))

        if character = characterAt(position)
          character.stun(1)

          element = "Fire"
          character.damage(1, element)

          unless character.immune(element)
            message "#{character.name()} is on fire!"

    Effect.Move = (from, to, movingCharacter=null) ->
      perform: ({animate, characterAt, message, impassable, event}) ->
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
              character: character
              from: from
              to: to

            animate
              position: to
              duration: 100
        else
          console.log "No character at", from

    Effect.PestilentVapor = (position) ->
      perform: ({feature}) ->
        feature "PestilentVapor", position

    Effect.Crush = (position) ->
      perform: ({featuresAt}) ->
        # TODO figure out why this doesn't
        # remove the tiles immediately. It
        # happens the next round.
        featuresAt(position).invoke "destroy"

    Effect.Demolish = (position, owner) ->
      perform: ({message, featuresAt, replaceTileAt}) ->
        featuresAt(position).invoke "destroy"
        replaceTileAt(position)

        message "#{owner.name()} demolishes everything in their path."

    Effect.Stomp = (position, owner) ->
      perform: ({characterAt, message, search, featuresAt, replaceTileAt}) ->
        # TODO: Add cracked / destroyed sprite
        # TODO: Screen shake
        search.adjacent(position).forEach (position) ->
          if character = characterAt(position)
            unless character is owner
              message "#{character.name()} has been shaken by the mighty stomp of #{owner.name()}."
              character.damage(1)
              character.stun(2)

          featuresAt(position).invoke "destroy"

          # Revert tiles to default
          replaceTileAt(position)

    Effect.Ice = (position) ->
      perform: ({addFeature}) ->
        addFeature Feature.Ice(position)

    Effect.Flame = (position) ->
      perform: ({addFeature}) ->
        addFeature Feature.Fire(position)

    Effect.Acid = (position) ->
      perform: ({addFeature}) ->
        addFeature Feature.Acid(position)

    Effect.Oil = (position) ->
      perform: ({addFeature}) ->
        addFeature Feature.Slime(position)

    # Used in Entanglement
    Effect.Plant = (position) ->
      perform: ({animate, characterAt, message, addFeature, impassable}) ->
        unless impassable(position)
          # TODO: Check for existing bushes
          addFeature Feature.Bush(position)

        if character = characterAt(position)
          character.stun(1)

          animate
            message: "#{character.name()} is caught in a shrub!"
            duration: 100

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

    Effect.Entomb = (position) ->
      perform: ({search, replaceTileAt}) ->
        search.adjacent(position).forEach (position) ->
          replaceTileAt(position, 2)

    Effect.Stonesight = (position, owner) ->
      # TODO: Redo this 'find' idea to make use of the quadtree
      # build in radii, etc
      perform: ({findTiles}) ->
        findTiles
          position: position
          type: 2 # TODO: Have tile types not this magic number jazz
          radius: 13
        .forEach owner.addMagicalVision
