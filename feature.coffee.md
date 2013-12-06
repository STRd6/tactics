Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Compositions = require "./lib/compositions"
    Drawable = require "./lib/drawable"
    Type = require "./type"

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
        createdAt: 0
        destroyed: false
        impassable: false
        movementPenalty: 0
        opaque: false
        type: Type.Dirt
        zIndex: -1

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

      self.extend
        destroy: ->
          if !I.destroyed
            I.destroyed = true

        update: (params) ->
          # TODO: Allow for variable number of squads
          numSquads = 2
          {turn} = params

          params.position = self.position()

          delta = turn - I.createdAt

          if I.spriteName is "ogre"
            console.log delta

          if (delta > 0) and (delta % numSquads is 0)
            I.update?(params)

            if I.duration?
              return delta < I.duration

          return !I.destroyed

      return self

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

    Feature.Fire = (position) ->
      Feature
        duration: 1
        position: position
        spriteName: "ogre"
        type: Type.Fire
        zIndex: 1
        update: ({addFeature, characterAt, position, message, find}) ->
          radius = Math.sqrt(2)

          # TODO: Only have adding effects here, no finding features
          find("plant").within(position, radius).forEach (plant) ->
            if plant.destroy()
              addFeature(Feature.Fire(plant.position()))

          if character = characterAt(position)
            amount = 1

            character.damage(amount)
            message "The fire burns #{character.name()} for #{amount} damage."
