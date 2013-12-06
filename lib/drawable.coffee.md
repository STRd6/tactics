Drawable
========

    # TODO: Package up both drawable and resource into a library
    Resource = require "../resource"

    module.exports = (I={}, self=Core(I)) ->
      self.extend
        draw: ->
          self.sprite()?.draw arguments...

        sprite: ->
          Resource.sprite(I.spriteName)
