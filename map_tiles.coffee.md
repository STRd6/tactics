Map Tiles
=========

    BitArray = require "bit_array"
    ByteArray = require "byte_array"

    Tileset = require "./tileset"

Methods for interacting with tiles witin the map.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        width: 32
        height: 18

      tileset = Tileset()

      self.attrAccessor "width", "height"

      self.tileCount = ->
        I.width * I.height

      Object.defaults I,
        tiles: "data:application/octet-binary;BQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQsFBQUFBQsFBQUFBQUFBQUFBQUFBQULBQUFBQUFBQUFBQUFBQUFBRoaBQUFBQUFCwUFBQsFBQUFBQUFBQsFBQUFBQUFGhoaGhoaGhoaGhoFBQUFBQUFBQUFCwUFBQUFBQUaGhoaGhoaGhoaGhoaGhoaGgUFBQUFBQUFBQUFBQUaGhoaGhoaGhoaGhoaGhoaGhoaGhoaBQsFBQUFBQUFBRoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaBQUFBQUFBQUFGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoFBQULBQULBQUaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoFBQUFBQUFBQUaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGgUFBQUFBQUFBRoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaBQUFBQUFBQUFBRoaGhoaGhoaGhoaGhoaGhoaGhoaGhoFBQUFBQULBQUFBQUaGhoaGhoaGhoaGhoaGhoaGhoaBQUFBQUFBQUFBQUFBQUFGhoaGhoaGhoaGhoaGhoaGgUFBQUFBQUFBQUFBQUFBQULBQUFGhoaGhoaBQUFBQUFBQULBQUFBQUFBQUFCwUFBQUFBQUFBQUFBQUFBQUFCwUFBQUFBQUFBQsFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQsFBQUFBQULBQUFBQUFBQUFBQUL"
        lit: [
          # TODO: Handle arbitrary number of squads
          # TODO: Maybe store these with the squad data itself?
          self.tileCount()
          self.tileCount()
        ]
        seen: [
          self.tileCount()
          self.tileCount()
        ]

      self.attrModel "tiles", ByteArray

      self.attrModels "lit", BitArray
      self.attrModels "seen", BitArray

      boundsCheck = (x, y) ->
        (0 <= x < self.width()) and (0 <= y < self.height())

      bitArrayLookup = (field) ->
        (x, y) ->
          if x.x?
            {x, y} = x

          if boundsCheck(x, y)
            field.get(self.activeSquadIndex()).get(x + y * self.width())

      toSingleDimension = (position) ->
        {x, y} = position

        x + y * self.width()

      self.extend
        isLit: bitArrayLookup(self.lit)

        isSeen: bitArrayLookup(self.seen)

        # TODO: Inculde character as an optional parameter
        impassable: (position) ->
          if tileset.isImpassable(self.tileIndexAt(position))
            return true

          self.featuresAt(position).some (feature) ->
            feature.impassable()

        # TODO: Include character as an optional parameter
        opaque: (position) ->
          if tileset.isOpaque(self.tileIndexAt(position))
            return true

          self.featuresAt(position).some (feature) ->
            feature.opaque()

        tileIndexAt: (position) ->
          self.tiles().get(toSingleDimension(position))

        tileAt: (position) ->
          {x, y} = position

          if boundsCheck(x, y)
            index = self.tileIndexAt(position)
            # TODO: Refine tile variation selector
            tileset.tileFor(index, x, y)

        replaceTileAt: (position) ->
          self.tiles().set(toSingleDimension(position))

        viewTiles: ({positions, index, type, message}) ->
          positions.forEach (position) ->
            {x, y} = position

            if boundsCheck(x, y)
              n = toSingleDimension(position)
              self.lit.get(index).set(n, 1)
              self.seen.get(index).set(n, 1)
              self.featuresAt(position).forEach (feature) ->
                feature.view(index, type, message)

        updateVisibleTiles: ({message}) ->
          self.lit [0...self.squads().length].map ->
            BitArray(self.tileCount())

          self.squads().forEach (squad, index) ->
            squad.characters().filter (character) ->
              character.alive()
            .forEach (character) ->
              # Magical vision
              self.viewTiles
                index: index
                message: message
                positions: character.magicalVision()
                type: "magic"

              # Physical sensing
              self.viewTiles
                index: index
                message: message
                positions: self.search.adjacent(character.position(), character.physicalAwareness())
                type: "physical"

              # Normal Sight
              self.viewTiles
                index: index
                message: message
                positions: self.search.visible(character.position(), character.sight(), self.opaque)
                type: character.visionType()

      # Add Features from tileset
      # In order to use a layerless editor we transform some tile values into 
      # others and create a given feature at the position
      I.height.times (y) ->
        I.width.times (x) ->
          position = {x, y}
          {feature, index} = tileset.dataAt self.tileIndexAt(position)

          if feature
            index ?= tileset.defaultIndex()
            self.tiles().set(toSingleDimension(position), index)

            self.addFeatureByName(feature, position)

      return self
