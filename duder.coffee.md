Duder
=====

Those little guys that run around.

Use Shadowcasting for FoV calculations.

    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)
      I.sprite = Resource.sprite(I.sprite)
      I.sight ?= 7
      I.move ?= 5

      self.attrAccessor "position", "sprite", "sight"

      fov = new Shadowcasting()
      fov.tileAt = (args...) ->
        self.tileAt(args...)

      self.visibleTiles = ->
        fov.calculate(self.position(), self.sight())

      self.updatePosition = (newPosition) ->
        self.position newPosition

      return self
