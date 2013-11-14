Duder
=====

Those little guys that run around.

Use Shadowcasting for FoV calculations.

    Resource = require "./resource"
    Shadowcasting = require "./shadowcasting"

    module.exports = (I={}, self=Core(I)) ->
      I.position = Point(I.position)
      I.sprite = Resource.sprite(I.sprite)

      Object.defaults I,
        sight: 7
        movement: 4
        health: 3
        healthMax: 3
        actions: 2

      self.attrAccessor(
        "actions"
        "movement"
        "position"
        "sprite"
        "sight"
      )

      fov = new Shadowcasting()
      fov.tileAt = (args...) ->
        self.tileAt(args...)

      self.visibleTiles = ->
        fov.calculate(self.position(), self.sight())

      self.move = (newPosition) ->
        I.actions -= 1
        self.position newPosition

      self.updatePosition = (newPosition) ->
        self.position newPosition

Ready is called at the beginning of each turn. It resets the actions and processes
any status effects.

      self.ready = ->
        I.actions = 2

      return self
