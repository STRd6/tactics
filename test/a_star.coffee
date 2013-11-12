Graph = require "../graph"

describe "A*", ->
  it "should find the shortest path between nodes", ->
    result = Graph.aStar
      initial:0
      goal: 10
      neighbors: (value) ->
        [
          [value - 1, 1]
          [value + 1, 1]
        ]
      heuristic: (node, goal) ->
        (goal - node).abs()
    
    assert.equal result.length, 11

describe "accessible", ->
  it "should list the node that are accessible within the distance", ->
    result = Graph.accessible
      initial:0
      distanceMax: 5
      neighbors: (value) ->
        [
          [value - 1, 1]
          [value + 1, 1]
        ]

    assert.equal result.length, 11
