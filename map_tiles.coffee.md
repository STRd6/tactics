Map Tiles
=========

    MapTile = require "./map_tile"
    {Grid} = require "./lib/util"

Methods for interacting with tiles witin the map.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        tiles:
          width: 32
          height: 18
          # TODO: Make this into bit/byte arrays
          data: [0... 32 * 18].map ->
            {}

      I.tiles.constructor = MapTile
      self.attrModel "tiles", Grid

      self.extend
        tileAt: self.tiles().get

        # TODO: Add trap detection
        # TODO: Keep track of seen features as well as seen tiles
        viewTiles: (positions, index) ->
          positions.map(self.tileAt).forEach (tile) ->
            tile?.view index

        updateVisibleTiles: ->
          self.eachTile (tile) ->
            tile.resetLit()

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
