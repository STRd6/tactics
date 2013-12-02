Map Serialization
=================

    module.exports = (I={}, self) ->
      self.extend
        toJSON: ->
          tiles: self.tiles.toJSON()
