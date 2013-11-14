Action
======

The only thing persons can do in the game are actions.

They live in a little menu that changes based on the context.

Clicking on them makes them happen.

    Resource = require "./resource"

    module.exports = (I={}) ->
      self = {}

      Object.defaults self, I,
        name: "Action"

      self.icon = Resource.dataURL(I.icon)

      return self
