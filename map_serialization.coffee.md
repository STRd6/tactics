Map Serialization
=================

    module.exports = (I={}, self) ->
      self.extend
        toJSON: ->
          I
