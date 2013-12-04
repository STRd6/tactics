Feature
=======

Features are things that are present within tiles in the tactical combat view.

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
        "position"
        "type"
        "zIndex"
      )

      self.include Drawable

      Object.extend self,
        destroy: ->
          if !I.destroyed
            I.destroyed = true

        update: ({turn}) ->
          delta = turn - I.createdAt

          if (delta > 0) and (delta % 1 is 0)
            I.update?(arguments...)

            if I.duration?
              delta < I.duration

          return !I.destroyed

      return self

    Feature.Wall = ->
      Feature
        impassable: true
        opaque: true
        spriteName: "brick_vines" + rand(4)
        type: Type.Stone

    Feature.Bush = (position) ->
      Feature
        opaque: true
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

          find("plant").within(position, radius).forEach (plant) ->
            if plant.destroy()
              addFeature(Feature.Fire(plant.position()))

          if character = characterAt(position)
            amount = 1

            character.damage(amount)
            message "The fire burns #{character.name()} for #{amount} damage."
