Duder
=====

Those little guys that run around.

Use Shadowcasting for FoV calculations.

    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)
      I.sprite = Resource.sprite(I.sprite)

      self.attrAccessor "position", "sprite"

      fov = new Shadowcasting(self.position(), 7)
      fov.tileAt = (args...) ->
        self.tileAt(args...)

      self.updateFOV = ->
        fov.update(self.position())
        fov.calculate()

      self.updatePosition = (newPosition) ->
        self.position newPosition
        self.updateFOV()

      return self
