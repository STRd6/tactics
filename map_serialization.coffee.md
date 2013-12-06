Map Serialization
=================

    module.exports = (I={}, self) ->
      self.extend
        toJSON: ->
          Object.extend {}, I,
            seen: self.seen().map (seen) -> seen.toJSON()
            lit: self.lit().map (lit) -> lit.toJSON()
            tiles: self.tiles().toJSON()
