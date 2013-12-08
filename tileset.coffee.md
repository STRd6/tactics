Tileset
=======

    BitArray = require "bit_array"
    Compositions = require "./lib/compositions"
    Resource = require "./resource"

Hold a list of tiles with their passable/occlusion info as well as alternate
art.

    n = 256

    tileset = new Array(n)

    tileset[5] = [0...8].map (n) ->
      Resource.sprite("ground#{n}")

    tileset[11] = tileset[5]

    tileset[26] = [0...4].map (n) ->
      Resource.sprite("brick_vines#{n}")

    notFound = {}

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        impassable: n
        opaque: n

      self.include Compositions

      self.attrModel "impassable", BitArray
      self.attrModel "opaque", BitArray

      # TODO: Don't hard code this
      self.impassable().set(26, 1)
      self.opaque().set(26, 1)

      self.extend
        isImpassable: (index) ->
          self.impassable().get(index)

        isOpaque: (index) ->
          self.opaque().get(index)

        tileFor: (index, x, y) ->
          if group = tileset[index]
            group.wrap(x + y)
          else
            unless notFound[index]
              console.error "Index not present in tileset: index #{index}"
              notFound[index] = true

            tileset[defaultIndex].wrap(x + y)

        toJSON: ->
          Object.extend {}, I,
            impassable: self.impassable().toJSON()
            opaque: self.opaque().toJSON()
