Map Serialization
=================

    module.exports = (I={}, self) ->
      self.extend
        toJSON: ->
          Object.extend {}, I,
            squads: self.squads().invoke "toJSON"
            seen: self.seen().invoke "toJSON"
            lit: self.lit().invoke "toJSON"
            tiles: self.tiles().toJSON()
