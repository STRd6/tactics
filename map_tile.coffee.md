Map Tile
========

TODO: We should probably phase this class out in favor of map methods. That way
we can have lit and seen as bit arrays.

TODO: Use an int for the tile index rather than sprite name.

A tile in the tactical combat screen.

    Drawable = require "./lib/drawable"

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        spriteName: "ground0"

      self.include Drawable

      self.attrAccessor "spriteName"

      return self
