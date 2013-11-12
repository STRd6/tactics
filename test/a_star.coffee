Graph = require "../graph"

describe "A*", ->
  it "should find the shortest path between nodes", ->
    console.log Graph.aStar
      initial:0
      goal: 10
      neighbors: (value) ->
        [
          [value - 1, 1]
          [value + 1, 1]
        ]
      heuristic: (node, goal) ->
        (goal - node).abs()
