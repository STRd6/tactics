Map Search
==========

    Graph = require "./graph"

Here's a dumping ground for all the specifics of how we use A* and other graph
search algorithms with our tile data objects. It's the glue between
abstract graph searching and our concrete implementation.

    cardinalDirections = [
      Point(1, 0)
      Point(-1, 0)
      Point(0, 1)
      Point(0, -1)
    ]

Return an array of [position, cost] pairs that represents locations that can
be reached immediately from the given position.

The passed in `get` function returns the tile for a given position so that we
may query its properties and figure out what to do.

    neighborsVisible = (position, getTile, getEntities) ->
      # TODO: Add diagonals if both edges are passable
      cardinalDirections.map (direction) ->
        position.add(direction)
      .filter (position) ->
        # Filter out any impassible or unlit tiles
        tile = getTile(position)
        tile and !tile.solid and tile.lit
      .filter (position) ->
        # Filter out any tiles with peeps on them
        # TODO: Pass through friendly peeps
        !getEntities(position)
      .map (position) ->
        [position, 1]

    strategy = (pattern, getTile, getEntities) ->
      (position) -> 
        pattern(position, getTile, getEntities)

    module.exports = (getTile, getEntities) ->

Returns a list of all positions accessible to the duder by normal movement
through tiles.

      accessible: (duder) ->
        Graph.accessible
          initial: duder.position()
          neighbors: strategy neighborsVisible, getTile, getEntities
          distanceMax: duder.movement()

      movementPath: (duder, target) ->
        Graph.aStar
          initial: duder.position()
          goal: target
          neighbors: strategy neighborsVisible, getTile, getEntities
          heuristic: (a, b) ->
            {x, y} = b.subtract(a).abs()

            x + y # Manhattan distance
