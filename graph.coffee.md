Graph Search
============
    PriorityQueue = require "priority_queue"

    module.exports =

A* Pathfinding

Return a path from initial to goal or `undefined` if no path exists.

Initial and goal are assumed to be nodes that have a toString function that
uniquely identifies nodes.

      aStar: ({initial, goal, heuristic, neighbors}) ->
        heuristic ?= -> 0
        neighbors ?= -> []

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
          console.log nodes
          path = [node]

          while (node = nodes[node].parent) != null
            path.push node

          return path.reverse()

        push initial, null, 0

        while openSet.size() > 0
          current = openSet.pop()

          if current is goal
            return getPath(goal)

          neighbors(current).forEach ([node, distance]) ->
            push node, current, distance
