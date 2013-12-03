Map Tile
========

TODO: We should probably phase this class out in favor of map methods. That way
we can have lit and seen as bit arrays.

TODO: Use an int for the tile index rather than sprite name.

A tile in the tactical combat screen.

    Drawable = require "./lib/drawable"

    # TODO: We may want to move features out of these arrays
    # and flatten them into map chunks

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        features: []
        lit: []
        seen: []
        spriteName: "ground0"

      self.include Drawable

      self.attrAccessor "features", "spriteName"

      self.extend
        addFeature: (feature) ->
          I.features.push feature

        hasType: (type) ->
          I.features.some (feature) ->
            feature.type() is type

        lit: (index) ->
          I.lit[index]

        seen: (index) ->
          I.seen[index]

        view: (index) ->
          I.lit[index] = I.seen[index] = true

        resetLit: ->
          I.lit.forEach (_, i) ->
            I.lit[i] = false

        updateFeatures: (params) ->
          I.features = I.features.select (feature) ->
            feature.update(params)

        # TODO: Calculate based on character abilities
        impassable: ->
          I.features.some (feature) ->
            feature.impassable()

        # TODO: Calculate based on character abilities
        opaque: ->
          I.features.some (feature) ->
            feature.opaque()

      return self
