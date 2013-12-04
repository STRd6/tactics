Map Tiles
=========

    BitArray = require "bit_array"
    MapTile = require "./map_tile"
    {Grid} = require "./lib/util"

    mapWidth = 32
    mapHeight = 18
    numberOfTiles = mapWidth * mapHeight

Methods for interacting with tiles witin the map.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        tiles:
          width: self.width()
          height: self.height()
          # TODO: Make this into bit/byte arrays
          data: [0... 32 * 18].map ->
            {}
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

      I.tiles.constructor = MapTile
      self.attrModel "tiles", Grid

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

        tileAt: self.tiles().get

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
