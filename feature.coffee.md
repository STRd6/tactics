Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Resource = require "./resource"
    Sprite = require "sprite"
    Type = require "./type"

    # TODO we don't have tileAt, so we can't do all searches
    search = require("./map_search")()

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
        createdAt: 0
        movementPenalty: 0
        opaque: false
        type: Type.Dirt
        zIndex: -1

      self.attrAccessor(
        "movementPenalty"
        "opaque"
        "type"
        "zIndex"
      )

      Object.extend self,
        draw: ->
          self.sprite().draw arguments...
        sprite: ->
          Resource.sprite(I.spriteName) or Sprite.NONE
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

    Feature.Bush = ->
      Feature
        spriteName: "bush" + rand(4)
        type: Type.Plant
        zIndex: 1

    Feature.Fire = ->
      Feature
        duration: 1
        spriteName: "ogre"
        zIndex: 1
        update: ({addFeature, characterAt, position, message, tileAt}) ->
          search.adjacent(position).forEach (position) ->
            if tile = tileAt(position)
              shrubsOnFire = false

              tile.features.select( (feature) ->
                # TODO: apply this to all flammable things
                feature.type() is "plant"
              ).forEach (plantFeature) ->
                tile.features.remove(plantFeature)
                shrubsOnFire = true

              if shrubsOnFire
                # TODO fix visibility
                tile.opaque = false
                addFeature(Feature.Fire(), position)

          if character = characterAt(position)
            amount = 1

            character.damage(amount)
            message "The fire burns #{character.name()} for #{amount} damage."
