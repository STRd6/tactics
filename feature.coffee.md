Feature
=======

Features are things that are present within tiles in the tactical combat view.

    Resource = require "./resource"
    Sprite = require "sprite"
    Type = require "./type"

    module.exports = Feature = (I={}, self=Core(I)) ->
      Object.defaults I,
        age: 0
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
        update: ->
          I.age += 1

          I.update?(arguments...)

          if I.duration?
            I.age < I.duration
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
        update: ({characterAt, position, message}) ->
          if character = characterAt(position)
            amount = 1

            character.damage(amount)
            message "The fire burns #{character.name()} for #{amount} damage."
