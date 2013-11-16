Map Search
==========

    Graph = require "./graph"
    {sqrt} = Math

    {
      indexOf
      intersection
      unique
      without
    } = require "./array_helpers"

Here's a dumping ground for all the specifics of how we use A* and other graph
search algorithms with our tile data objects. It's the glue between
abstract graph searching and our concrete implementation.

    cardinalDirections = [
      Point(0, -1)
      Point(1, 0)
      Point(0, 1)
      Point(-1, 0)
    ]

    calculateDiagonals = (directions) ->
      results = []
      directions.eachPair (a, b) ->
        results.push a.add(b)

      without(unique(results), Point.ZERO)

    ordinalDirections = calculateDiagonals(cardinalDirections)

    directionsWithCosts = cardinalDirections.map (direction) ->
      [direction, 1]
    .concat ordinalDirections.map (direction) ->
      [direction, sqrt(2)]

Return an array of [position, cost] pairs that represents locations that can
be reached immediately from the given position.

The passed in `get` function returns the tile for a given position so that we
may query its properties and figure out what to do.

    neighborsVisible = (position, getTile, getEntities, index) ->
      # TODO: Add diagonals if both edges are passable
      cardinalDirections.map (direction) ->
        position.add(direction)
      .filter (position) ->
        # Filter out any impassible or unlit tiles
        tile = getTile(position)
        tile and !tile.solid and tile.lit[index]
      .filter (position) ->
        # Filter out any tiles with peeps on them
        # TODO: Pass through friendly peeps
        !getEntities(position)
      .map (position) ->
        [position, 1]

    adjacentPositions = (position) ->
      directionsWithCosts.map ([direction, cost]) ->
        [position.add(direction), cost]

    strategy = (pattern, getTile, getEntities, index) ->
      (position) ->
        pattern(position, getTile, getEntities, index)

    module.exports = (getTile, getEntities) ->

Returns a list of all positions accessible to the duder by normal movement
through tiles.

      accessible: (duder, range, squadIndex) ->
        Graph.accessible
          initial: duder.position()
          neighbors: strategy neighborsVisible, getTile, getEntities, squadIndex
          distanceMax: range

      adjacent: (duder, range=sqrt(2)) ->
        Graph.accessible
          initial: duder.position()
          neighbors: adjacentPositions
          distanceMax: range

      movementPath: (duder, target, squadIndex) ->
        Graph.aStar
          initial: duder.position()
          goal: target
          neighbors: strategy neighborsVisible, getTile, getEntities, squadIndex
          heuristic: (a, b) ->
            {x, y} = b.subtract(a).abs()

            x + y # Manhattan distance
