Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Animation = require "./lib/animation"
    Compositions = require "./lib/compositions"
    Drawable = require "./lib/drawable"
    Type = require "./type"

    {sqrt} = Math

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
        createdAt: 0
        destroyed: false
        impassable: false
        incorporeal: false
        invisible: false
        movementPenalty: 0
        opaque: false
        trap: false
        type: Type.Dirt
        zIndex: -1
        seen: []

      self.attrAccessor(
        "createdAt"
        "impassable"
        "movementPenalty"
        "opaque"
        "type"
        "zIndex"
      )

      self.include Compositions
      self.include Drawable

      self.attrModel "position", Point
      self.attrModel "animation", Animation

      self.extend
        currentAnimation: ->
          self.animation()

        # TODO: Dangerous should depend on the character
        dangerous: ->
          I.trap

        destroy: ->
          if !I.destroyed
            I.destroyed = true

        view: (index, type, message) ->
          if (type is "magic") or (!I.invisible and type is "sight") or (!I.incorporeal and type is "physical")
            if !I.seen[index]
              if I.trap
                message "A trap has been uncovered! #{self.position()}"
              else if I.invisible
                message "An invisible object has been uncovered! #{self.position()}"

            I.seen[index] = true

        seen: (index) ->
          I.seen[index]

        enter: (params) ->
          I.enter?.call(I, params)

        update: (params) ->
          # TODO: Allow for variable number of squads
          numSquads = 2
          {turn} = params

          params.position = self.position()

          delta = turn - I.createdAt

          if (delta > 0) and (delta % numSquads is 0)
            I.update?(params)

            if I.duration?
              return delta < I.duration

          return !I.destroyed

      return self

    Feature.Acid = (position) ->
      Feature
        position: position
        spriteName: "acid"
        type: Type.Acid
        update: ({characterAt, position, message}) ->
          if character = characterAt(position)
            amount = 1

            element = "Acid"
            character.damage(amount, element)

            unless character.immune(element)
              message "The acid burns #{character.name()} for #{amount} damage."

    Feature.Slime = (position) ->
      Feature
        position: position
        spriteName: "oil"
        type: Type.Oil

    Feature.Wall = (position) ->
      Feature
        impassable: true
        position: position
        opaque: true
        spriteName: "brick_vines" + rand(4)
        type: Type.Stone

    Feature.Bush = (position) ->
      Feature
        opaque: true
        position: position
        spriteName: "bush" + rand(4)
        type: Type.Plant
        zIndex: 1

    Feature["Stun Gas"] = (position) ->
      Feature
        duration: 1
        position: position
        spriteName: "green_cloud"
        zIndex: 1
        trap: true
        enter: ({characterAt, message}) ->
          if character = characterAt(position)
            message "#{character.name()} is engulfed in a cloud of noxious fumes!"
            character.stun(2)
        update: ({characterAt, message}) ->
          if character = characterAt(position)
            message "#{character.name()} is engulfed in a cloud of noxious fumes!"
            character.stun(2)

    Feature.PestilentVapor = (position) ->
      Feature
        duration: 1
        position: position
        spriteName: "pestilent_vapor"
        zIndex: 1
        update: ({feature, message, position, search}) ->
          radius = sqrt(2)

          message "The pestilent vapor erupts into a cloud of death!"

          search.adjacent(position, radius).forEach (position) ->
            feature "DeathCloud", position

    Feature.DeathCloud = (position) ->
      Feature
        duration: 1
        position: position
        spriteName: "black_cloud"
        zIndex: 1
        update: ({characterAt, message}) ->
          if character = characterAt(position)
            element = "Death"
            character.damage 10, element

            unless character.immune(element)
              message "#{character.name()} is surrounded by choking fumes!"

    Feature.Ice = (position) ->
      Feature
        duration: 3
        position: position
        spriteName: "frozen0"
        animation: ["frozen0", "frozen1", "frozen2", "frozen3"]
        type: Type.Ice
        impassable: true

    Feature.Fire = (position) ->
      Feature
        duration: 1
        position: position
        spriteName: "fire"
        animation: ["fire0", "fire1"]
        type: Type.Fire
        zIndex: 1
        update: ({addFeature, characterAt, position, message, find}) ->
          radius = sqrt(2)

          # TODO: Only have adding effects here, no finding features
          find("plant").within(position, radius).forEach (plant) ->
            if plant.destroy()
              addFeature(Feature.Fire(plant.position()))

          if character = characterAt(position)
            amount = 1

            element = "Fire"
            character.damage(amount, element)

            unless character.immune(element)
              message "The fire burns #{character.name()} for #{amount} damage."

    Feature.Traps =
      Effect: (position, effectName) ->
        Feature
          effectName: effectName
          invisible: true
          position: position
          spriteName: "trap"
          trap: true
          # TODO: Can't have Feature depend on Effect and Effect depend on Feature
          # so the method passed in should coordinate both
          # We'll migrate all of these to creating named effects with optional
          # configuration data
          enter: ({effect}) ->
            # TODO: Destroy?

            effect @effectName, @position
