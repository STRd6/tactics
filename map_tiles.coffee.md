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
            features: []

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

          self.squads().forEach (squad, i) ->
            squad.characters().filter (character) ->
              character.alive()
            .forEach (duder) ->
              # Magical vision
              self.viewTiles duder.magicalVision(), i

              # Physical sensing
              self.viewTiles self.search.adjacent(duder.position()), i

              # Normal Sight
              self.viewTiles self.search.visible(duder.position(), duder.sight()), i

      return self
