Tileset
=======

    BitArray = require "bit_array"
    Compositions = require "./lib/compositions"
    Resource = require "./resource"

Hold a list of tiles with their passable/occlusion info as well as alternate
art.

    n = 256

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        impassable: n
        opaque: n
        size: 256
        spriteNames: # TODO: This should probably be an array
          2:
            name: "brick_vines" # TODO: Cave wall
            count: 4
            impassable: true
            opaque: true
          5:
            name: "ground"
            count: 8
          11:
            feature: "Bush"
          22:
            name: "ground" # TODO: Cave floor
            count: "8"
          26:
            name: "brick_vines"
            count: 4
            impassable: true
            opaque: true
        defaultIndex: 5

      self.attrAccessor "defaultIndex"

      self.include Compositions

      self.attrModel "impassable", BitArray
      self.attrModel "opaque", BitArray

      tileSprites = new Array(n)

      # Using keys to handle "sparse" arrays.
      Object.keys(I.spriteNames).map (index) ->
        nameOrObject = I.spriteNames[index]

        if typeof nameOrObject is "string"
          tileSprites[index] = [Resource.sprite(nameOrObject)]
        else
          {name, count, impassable, opaque} = nameOrObject

          if name
            tileSprites[index] = [0...count].map (n) ->
              Resource.sprite("#{name}#{n}")

          if impassable
            self.impassable().set(index, 1)

          if opaque
            self.opaque().set(index, 1)

      notFound = {}

      self.extend
        dataAt: (index) ->
          I.spriteNames[index]

        isImpassable: (index) ->
          self.impassable().get(index)

        isOpaque: (index) ->
          self.opaque().get(index)

        tileFor: (index, x, y) ->
          if group = tileSprites[index]
            group.wrap(x + y)
          else
            unless notFound[index]
              console.error "Index not present in tileset: index #{index}"
              notFound[index] = true

            tileSprites[I.defaultIndex].wrap(x + y)

        toJSON: ->
          Object.extend {}, I,
            impassable: self.impassable().toJSON()
            opaque: self.opaque().toJSON()
