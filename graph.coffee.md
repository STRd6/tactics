Graph Search
============
    PriorityQueue = require "priority_queue"

    module.exports =

A* Pathfinding

Return a path from initial to goal or `undefined` if no path exists.

Initial and goal are assumed to be nodes that have a toString function that
uniquely identifies nodes.

      aStar: ({initial, goal, heuristic, neighbors, equals}) ->
        heuristic ?= -> 0
        neighbors ?= -> []
        equals ?= (a, b) ->
          a.toString() == b.toString()

        # Prevent hanging by capping max iterations
        iterations = 0
        iterationsMax = 1000

        # Table to track our node meta-data
        nodes = {}

        openSet = PriorityQueue
          low: true

        push = (node, current, distance=1) ->
          g = nodes[node]?.g ? Infinity
          h = nodes[node]?.h ? heuristic(node, goal)

          nodeData =
            g: (nodes[current]?.g ? 0) + distance
            h: h
            parent: current
            node: node

          # Update if better
          if nodeData.g < g
            nodes[node] = nodeData
            openSet.push node, nodeData.g + h

        getPath = (node) ->
          path = [node]

          while (node = nodes[node].parent) != null
            path.push node

          return path.reverse()

        push initial, null, 0

        while openSet.size() > 0
          return if iterations >= iterationsMax
          iterations += 1

          current = openSet.pop()

          if equals current, goal
            return getPath(goal)

          neighbors(current).forEach ([node, distance]) ->
            push node, current, distance

Find all the nodes accessible within the given distance.

      accessible: ({initial, neighbors, distanceMax}) ->
        neighbors ?= -> []
        distanceMax ?= 1

        # Table to track our node meta-data
        nodes = {}

        openSet = PriorityQueue
          low: true

        push = (node, current, distance=1) ->
          g = nodes[node]?.g ? Infinity

          nodeData =
            g: (nodes[current]?.g ? 0) + distance
            node: node

          # Update if better
          if nodeData.g < g and nodeData.g <= distanceMax
            nodes[node] = nodeData
            openSet.push node, nodeData.g

        push initial, null, 0

        while openSet.size() > 0
          current = openSet.pop()

          neighbors(current).forEach ([node, distance]) ->
            push node, current, distance

        Object.keys(nodes).map (key) ->
          nodes[key].node
