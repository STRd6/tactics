Map Tiles
=========

    BitArray = require "bit_array"
    ByteArray = require "byte_array"
    Resource = require "./resource"

    tileset = [0...8].map (n) ->
      Resource.sprite("ground#{n}")

Methods for interacting with tiles witin the map.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        tiles: self.tileCount()
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
      # TODO: Build variations into tileset
      [0...self.tileCount()].forEach (i) ->
        self.tiles().set(i, rand(8))

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

      self.extend
        isLit: bitArrayLookup(self.lit)

        isSeen: bitArrayLookup(self.seen)

        tileset: ->
          tileset

        tileAt: (x, y) ->
          if x.x?
            {x, y} = x

          if boundsCheck(x, y)
            self.tileset()[self.tiles().get(x + y * self.width())]

        # TODO: Add trap detection
        viewTiles: ({positions, index, type, message}) ->
          positions.forEach (position) ->
            {x, y} = position

            if boundsCheck(x, y)
              self.lit.get(index).set(x + y * self.width(), 1)
              self.seen.get(index).set(x + y * self.width(), 1)
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
                type: "sight"

      return self
