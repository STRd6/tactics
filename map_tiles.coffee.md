Map Tiles
=========

    BitArray = require "bit_array"
    ByteArray = require "byte_array"
    {Grid} = require "./lib/util"
    Resource = require "./resource"

    mapWidth = 32
    mapHeight = 18
    numberOfTiles = mapWidth * mapHeight

    tileset = [
      "ground0"
    ].map (name) ->
      Resource.sprite(name)

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

        tileAt: (x, y) ->
          if x.x?
            {x, y} = x

          if boundsCheck(x, y)
            tileset[self.tiles().get(x + y * self.width())]

        # TODO: Add trap detection
        viewTiles: (positions, index) ->
          positions.forEach ({x, y}) ->
            if boundsCheck(x, y)
              self.lit.get(index).set(x + y * mapWidth, 1)
              self.seen.get(index).set(x + y * mapWidth, 1)
              # TODO: Keep track of seen features

        updateVisibleTiles: ->
          self.lit [0...self.squads().length].map ->
            BitArray(self.tileCount())

          self.squads().forEach (squad, index) ->
            squad.characters().filter (character) ->
              character.alive()
            .forEach (character) ->
              # Magical vision
              self.viewTiles character.magicalVision(), index

              # Physical sensing
              self.viewTiles self.search.adjacent(character.position()), index

              # Normal Sight
              self.viewTiles self.search.visible(character.position(), character.sight(), self.opaque), index

      return self
