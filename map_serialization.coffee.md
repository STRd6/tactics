Map Serialization
=================

Eventually we'll want to auto-serialize these data model components, but until
we do we do it manually here instead.

    module.exports = (I={}, self) ->
      self.extend
        toJSON: ->
          extend {}, I,
            squads: self.squads().invoke "toJSON"
            seen: self.seen().invoke "toJSON"
            lit: self.lit().invoke "toJSON"
            tiles: self.tiles().toJSON()
