Map Generator
=============

    Feature = require "./feature"
    {Grid} = require "./lib/util"
    MapTile = require "./map_tile"

Hold the terrain and whatnot for a level.

    wall = ->
      MapTile
        spriteName: "ground" + rand(8)
        features: [Feature.Wall()]

    ground = ->
      bush = rand() < 0.1

      MapTile
        spriteName: "ground" + rand(8)
        features: [0...bush].map ->
          Feature.Bush()

    module.exports =
      generate: (size) ->
        Grid size, (x, y) ->
          if rand() < 0.10
            wall()
          else
            ground()
