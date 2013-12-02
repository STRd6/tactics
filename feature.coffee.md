Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Drawable = require "./lib/drawable"
    Type = require "./type"

    # TODO we don't have tileAt, so we can't do all searches
    search = require("./map_search")()

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
        createdAt: 0
        impassable: false
        movementPenalty: 0
        opaque: false
        type: Type.Dirt
        zIndex: -1

      self.attrAccessor(
        "impassable"
        "movementPenalty"
        "opaque"
        "type"
        "zIndex"
      )

      self.include Drawable

      Object.extend self,
        update: ({turn}) ->
          debugger if I.spriteName is "ogre"
          delta = turn - I.createdAt

          if (delta > 0) and (delta % 1 is 0)
            I.update?(arguments...)

            if I.duration?
              delta < I.duration
            else
              true
          else
            true

      return self

    Feature.Wall = ->
      Feature
        impassable: true
        opaque: true
        spriteName: "brick_vines" + rand(4)
        type: Type.Stone

    Feature.Bush = ->
      Feature
        opaque: true
        spriteName: "bush" + rand(4)
        type: Type.Plant
        zIndex: 1

    Feature.Fire = ->
      Feature
        duration: 1
        spriteName: "ogre"
        type: Type.Fire
        zIndex: 1
        update: ({addFeature, characterAt, position, message, tileAt}) ->
          search.adjacent(position).forEach (position) ->
            if tile = tileAt(position)
              shrubsOnFire = false

              tile.features().select( (feature) ->
                # TODO: apply this to all flammable things
                feature.type() is "plant"
              ).forEach (plantFeature) ->
                tile.features().remove(plantFeature)
                shrubsOnFire = true

              if shrubsOnFire
                addFeature(Feature.Fire(), position)

          if character = characterAt(position)
            amount = 1

            character.damage(amount)
            message "The fire burns #{character.name()} for #{amount} damage."
