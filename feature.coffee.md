Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Resource = require "./resource"
    Sprite = require "sprite"
    Type = require "./type"

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
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

      return self

    Feature.Bush = ->
      Feature
        spriteName: "bush" + rand(4)
        zIndex: 1
