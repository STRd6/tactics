Map Search
==========

    Graph = require "./graph"
    FOV = require "./field_of_vision"

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

    neighborsVisible = (position, getTile, getEntities, passable) ->
      # TODO: Add diagonals if both edges are passable
      cardinalDirections.map (direction) ->
        position.add(direction)
      .filter(passable)
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

      accessible: (position, range, passable) ->
        Graph.accessible
          initial: position
          neighbors: strategy neighborsVisible, getTile, getEntities, passable
          distanceMax: range

      adjacent: (position, range=sqrt(2)) ->
        Graph.accessible
          initial: position
          neighbors: adjacentPositions
          distanceMax: range

      visible: (position, range=1) ->
        FOV.calculate(getTile, position, range)

      movementPath: (position, target, passable) ->
        Graph.aStar
          initial: position
          goal: target
          neighbors: strategy neighborsVisible, getTile, getEntities, passable
          heuristic: (a, b) ->
            {x, y} = b.subtract(a).abs()

            x + y # Manhattan distance