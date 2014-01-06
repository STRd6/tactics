Map Find
========

    module.exports = (I={}, self) ->
      self.include require "finder"

      oldFind = self.find

      typeMatcher = (type, object) ->
        object.type() is type

      self.extend
        find: (selector) ->
          results = oldFind(self.features(), selector, typeMatcher)

          results.within = (position, radius) ->
            results.filter (result) ->
              Point.distance(result.position(), position) <= radius

          return results

        # TODO: Circular rather than square
        findTiles: ({type, position, radius}) ->
          {x, y} = position

          results = []

          [(y - radius)..(y + radius)].forEach (y) ->
            [(x - radius)..(x + radius)].forEach (x) ->
              results.push Point(x, y) if self.tileIndexAt({x, y}) is type

          return results

      return self
